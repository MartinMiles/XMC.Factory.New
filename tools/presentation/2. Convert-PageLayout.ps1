#
# Usege: & '.\2. Convert-PageLayout.ps1' -itemPath "/sitecore/content/Zont/Habitat/Home/home" -Url "http://rssbplatform.dev.local"

#

param(
    [string]$itemPath, # = "/sitecore/content/Zont/Habitat/Home/About Habitat/Introduction",
    [string]$Url, #      = "http://rssbplatform.dev.local/about-habitat/introduction",
    [string]$Layout      = "{C530C0D6-E215-4CE5-B0EC-90F6D636AF6A}"
)

# 1) Grab pure JSON from the helper
$helper     = Join-Path $PSScriptRoot 'Get-PlaceholdersStructure-NEW.ps1'
$jsonJoined = (& $helper -Url $Url 2>&1) -join "`n"
$idx        = $jsonJoined.IndexOf('{')
if ($idx -lt 0) {
    Write-Error "Helper did not return JSON."
    exit 1
}

$jsonText = $jsonJoined.Substring($idx).Trim()

if($jsonText -eq "{}") {
    Write-Warning "Skipping page '$itemPath' as unable to obtain a layout from the URL '$Url'."
    exit 0
}

# 2) Open SPE session
Set-Location $PSScriptRoot
$config  = Get-Content -Raw ../remoting/config.LOCAL.json | ConvertFrom-Json
Import-Module SPE -ErrorAction Stop
$session = New-ScriptSession `
    -ConnectionUri $config.connectionUri `
    -Username      $config.username `
    -SharedSecret  $config.SPE_REMOTING_SECRET

# 3) Invoke conversion on CM, echo back every line
$output = Invoke-RemoteScript `
    -Session     $session `
    -Raw         `
    -ErrorAction Stop `
    -ScriptBlock {

            # function Throw-ParseError { param($m) Write-Error $m; throw $m }


[bool]$processStandardValues = $true
[bool]$processPageLayout     = $true


Add-Type -AssemblyName "Newtonsoft.Json"
Add-Type -AssemblyName "System.Xml.Linq"

$uid2dyn = @{}   # uid to dynamic placeholder ID
$ph2dyn  = @{}   # final placeholder to dynamic placeholder ID

function SetField($item, $fieldId, $value) {
  if (-not $item.Editing.IsEditing) { $item.Editing.BeginEdit() }
  $item.Fields[$fieldId].Value = $value
  $item.Editing.EndEdit()
}

function GetLocalAttr($elem, $name) {
  $elem.Attributes() | Where-Object { $_.Name.LocalName -eq $name }
}

function SetLocalAttr($elem, $name, $value) {
  $a = GetLocalAttr $elem $name
  if ($a.Count) { $a[0].Value = $value } else { $elem.SetAttributeValue($name, $value) }
}

# 1) load JSON maps
# $jsonPath = [System.Web.Hosting.HostingEnvironment]::MapPath("~/App_Data/modules.json")
# if (-not (Test-Path $jsonPath)) { Throw "home.json not found: $jsonPath" }
$jsonRoot = [Newtonsoft.Json.Linq.JToken]::Parse($using:jsonText)
$all      = New-Object 'System.Collections.Generic.List[Newtonsoft.Json.Linq.JObject]'

function Rec([Newtonsoft.Json.Linq.JToken]$n) {
  if ($n -is [Newtonsoft.Json.Linq.JObject]) { $all.Add($n) }
  foreach ($c in $n.Children()) { Rec $c }
}
Rec $jsonRoot

$map       = @{}  # uid to xmc base placeholder
$parentMap = @{}  # uid to parent uid
$zeroGuid  = '00000000-0000-0000-0000-000000000000'

foreach ($o in $all) {
  if ($o.ContainsKey('uid') -and $o.ContainsKey('xmc')) {
    $u = $o['uid'].ToString().Trim('{}').ToLowerInvariant()
    $x = $o['xmc'].ToString()
    if ($u -and $x) { $map[$u] = $x }
  }
  if ($o.ContainsKey('uid') -and $o.ContainsKey('parent')) {
    $u = $o['uid'].ToString().Trim('{}').ToLowerInvariant()
    $p = $o['parent'].ToString().Trim('{}').ToLowerInvariant()
    if ($p -ne $u -and $p -ne $zeroGuid) { $parentMap[$u] = $p }
  }
}
Write-Host "Loaded mappings: uid>xmc=$($map.Count), parentMap=$($parentMap.Count)"

# 2) merge shared plus final layout XML
function MergeXml([string]$sharedXml, [string]$finalXml) {
  $master = [System.Xml.Linq.XDocument]::Parse($sharedXml)
  if (-not [string]::IsNullOrWhiteSpace($finalXml)) {
    $frag = [System.Xml.Linq.XDocument]::Parse($finalXml)
    foreach ($el in $frag.Root.Elements()) { $master.Root.Add($el) }
  }
  return $master.ToString()
}

# 3) two pass processing to ensure parents resolved before children
$counter = 1
function ProcessFull($xml) {
  $doc    = [System.Xml.Linq.XDocument]::Parse($xml)
  $cloud  = $Using:Layout
  $allR   = @($doc.Root.Elements() |
             Where-Object { $_.Name.LocalName -eq 'd' } |
             ForEach-Object { $_.Elements() | Where-Object { $_.Name.LocalName -eq 'r' } })
  $processedUids  = @{}
  $uid2ph         = @{}   # uid to its final placeholder path

  # capture rendering ID, UID, original placeholder for reporting
  $idMap           = @{}  # uid to rendering-definition-ID
  $originalPhMap   = @{}  # uid to old placeholder
  foreach ($r in $allR) {
    $aUid = $r.Attribute('uid')
    if ($aUid) {
      $key = $aUid.Value.Trim('{}').ToLowerInvariant()
      $aId = $r.Attribute('id')
      $idMap[$key]         = if ($aId) { $aId.Value } else { '' }
      $oPh = GetLocalAttr $r 'ph'
      $originalPhMap[$key] = if ($oPh.Count) { $oPh[0].Value } else { '' }
    }
  }

  # assign device GUID on each layout definition node
  $doc.Root.Elements() | Where-Object { $_.Name.LocalName -eq 'd' } |
    ForEach-Object { $_.SetAttributeValue('l', $cloud) }

  do {
    $didAny = $false
    foreach ($r in $allR) {
      $aU  = $r.Attribute('uid')
      $key = if ($aU) { $aU.Value.Trim('{}').ToLowerInvariant() } else { $null }
      if ($key -and $processedUids.ContainsKey($key)) { continue }

      # check parent resolution
      $parentKey = $null; $parentDyn = $null
      if ($key -and $parentMap.ContainsKey($key)) {
        $parentKey = $parentMap[$key]
        if ($uid2dyn.ContainsKey($parentKey) -and $uid2ph.ContainsKey($parentKey)) {
          $parentDyn = $uid2dyn[$parentKey]
        } else { continue }
      }

      # assign or reuse dynamic ID
      if ($key -and -not $uid2dyn.ContainsKey($key)) {
        $uid2dyn[$key] = $counter; $counter++
      }
      $dyn = if ($key) { $uid2dyn[$key] } else { $counter; $counter++ }

      # determine base placeholder
      if ($key -and $map.ContainsKey($key)) { $basePh = $map[$key] }
      else {
        $oPh    = GetLocalAttr $r 'ph'
        $basePh = if ($oPh.Count) { $oPh[0].Value } else { '' }
      }

      # build final placeholder path
      $leaf = $basePh.TrimEnd('/') -split '/' | Select-Object -Last 1
      if ($parentDyn) {
        $parentFinal = $uid2ph[$parentKey]
        $prefix      = if ($parentFinal.StartsWith("/")) { $parentFinal } else { "/$parentFinal" }
        $finalPh     = "$prefix/$leaf-0-$parentDyn"
      } else {
        $finalPh = "$leaf"
      }

      # record mappings
      if ($key) {
        $uid2ph[$key]        = $finalPh
        $processedUids[$key] = $true
      }
      $ph2dyn[$finalPh] = $dyn

      # rewrite parameters
      $oPr    = GetLocalAttr $r 'par'
      $old    = if ($oPr.Count) { $oPr[0].Value } else { '' }
      $parts  = if ($old) { $old.Split('&') } else { @() }
      $clean  = $parts |
                Where-Object { $_ -and -not $_.StartsWith('DynamicPlaceholderId=') } |
                Select-Object -Unique
      $cs     = ($clean -join '&').Trim('&')
      $newPar = if ($cs) { "DynamicPlaceholderId=$dyn&$cs" } else { "DynamicPlaceholderId=$dyn" }
      SetLocalAttr $r 'par' $newPar
      SetLocalAttr $r 'ph'  $finalPh

      Write-Host "  r uid='$key' par='$newPar' ph='$finalPh'"
      $didAny = $true
    }
  } while ($didAny -and ($processedUids.Count -lt $allR.Count))

  # report unresolved renderings
  $unresolved = $originalPhMap.Keys |
                Where-Object { -not $processedUids.ContainsKey($_) }
  if ($unresolved.Count) {
    Write-Host "The following renderings could not be resolved due to missing parent mapping:"
    foreach ($key in $unresolved) {
      $rId   = $idMap[$key]
      $oldPh = $originalPhMap[$key]
      Write-Host "- Rendering ID: $rId, UID: $key, Old placeholder: $oldPh"
    }
  }

  return $doc.ToString()
}

# 4) preserve root attributes
function PreserveRootAttrs($processedXml, $originalXml) {
  if ([string]::IsNullOrWhiteSpace($originalXml)) { return $processedXml }
  $orig = [System.Xml.Linq.XDocument]::Parse($originalXml)
  $new  = [System.Xml.Linq.XDocument]::Parse($processedXml)
  foreach ($a in $orig.Root.Attributes()) {
    $new.Root.SetAttributeValue($a.Name, $a.Value)
  }
  return $new.ToString()
}

# 5) apply to Sitecore item
Write-Host "Processing item: $itemPath"
$item = Get-Item -Path $Using:itemPath -ErrorAction Stop
$ids  = [Sitecore.FieldIDs]

if ($processStandardValues) {
  $std = $item.Template.StandardValues
  $sharedS = ProcessFull $std.Fields[$ids::LayoutField].Value
  SetField $std $ids::LayoutField $sharedS

  if (-not [string]::IsNullOrWhiteSpace($std.Fields[$ids::FinalLayoutField].Value)) {
    $mergedS = MergeXml $sharedS $std.Fields[$ids::FinalLayoutField].Value
    $procS   = ProcessFull $mergedS
    $withRt  = PreserveRootAttrs $procS $std.Fields[$ids::FinalLayoutField].Value
    SetField $std $ids::FinalLayoutField $withRt
  } else {
    Write-Host "Final Layout for standard values is empty, leaving as is."
  }
}

if ($processPageLayout) {
  $page = ProcessFull $item.Fields[$ids::LayoutField].Value
  SetField $item $ids::LayoutField $page

  if (-not [string]::IsNullOrWhiteSpace($item.Fields[$ids::FinalLayoutField].Value)) {
    $mergedP = MergeXml $page $item.Fields[$ids::FinalLayoutField].Value
    $procP   = ProcessFull $mergedP
    $withRtP = PreserveRootAttrs $procP $item.Fields[$ids::FinalLayoutField].Value
    SetField $item $ids::FinalLayoutField $withRtP
  } else {
    Write-Host "Final Layout for page item is empty, leaving as is."
  }
}

Write-Output ("`n`nAll done for " + $Using:itemPath)

    }
Stop-ScriptSession -Session $session



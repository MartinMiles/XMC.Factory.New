param(
    [string]$itemPath = "/sitecore/content/Zont/Habitat/Home/more",
    [string]$Url      = "http://rssbplatform.dev.local/more-info"
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
        -Verbose     `
        -ScriptBlock {

            # function Throw-ParseError { param($m) Write-Error $m; throw $m }



  [bool]  $processStandardValues = $true
  [bool]  $processPageLayout     = $true


Add-Type -AssemblyName "Newtonsoft.Json"
Add-Type -AssemblyName "System.Xml.Linq"

# initialize mappings
$uid2dyn = @{}
$ph2dyn  = @{}

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

# 1) Load JSON maps
# $jsonPath = [System.Web.Hosting.HostingEnvironment]::MapPath("~/App_Data/about.json")
# if (-not (Test-Path $jsonPath)) { Throw "more.json not found: $jsonPath" }
$jsonRoot = [Newtonsoft.Json.Linq.JToken]::Parse($Using:jsonText)
$all      = New-Object 'System.Collections.Generic.List[Newtonsoft.Json.Linq.JObject]'
function Rec([Newtonsoft.Json.Linq.JToken]$n) {
  if ($n -is [Newtonsoft.Json.Linq.JObject]) { $all.Add($n) }
  foreach ($c in $n.Children()) { Rec $c }
}
Rec $jsonRoot

$map       = @{}
$parentMap = @{}
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

# 2) Merge shared + final (unchanged)
function MergeXml([string]$sharedXml, [string]$finalXml) {
  $master = [System.Xml.Linq.XDocument]::Parse($sharedXml)
  if (-not [string]::IsNullOrWhiteSpace($finalXml)) {
    $frag = [System.Xml.Linq.XDocument]::Parse($finalXml)
    foreach ($el in $frag.Root.Elements()) { $master.Root.Add($el) }
  }
  return $master.ToString()
}

# 3) Process layout XML nodes with new placeholder logic
$counter = 1
function ProcessFull($xml) {
  $doc           = [System.Xml.Linq.XDocument]::Parse($xml)
  $cloud         = '{C530C0D6-E215-4CE5-B0EC-90F6D636AF6A}'
  $processedUids = @{}
  $uid2ph        = @{}    # New: map each uid to its final placeholder

  foreach ($d in $doc.Root.Elements() | Where-Object { $_.Name.LocalName -eq 'd' }) {
    $d.SetAttributeValue('l', $cloud)
    foreach ($r in $d.Elements() | Where-Object { $_.Name.LocalName -eq 'r' }) {
      $aU  = $r.Attribute('uid')
      $key = if ($aU) { $aU.Value.Trim('{}').ToLowerInvariant() } else { $null }

      if ($key -and $processedUids.ContainsKey($key)) {
        $r.Remove(); continue
      }

      if ($key -and -not $uid2dyn.ContainsKey($key)) {
        $uid2dyn[$key] = $counter; $counter++
      }
      $dyn = if ($key) { $uid2dyn[$key] } else { $counter; $counter++ }
      if ($key) { $processedUids[$key] = $true }

      # base placeholder from JSON xmc or existing attribute
      if ($key -and $map.ContainsKey($key)) { $basePh = $map[$key] }
      else {
        $oPh    = GetLocalAttr $r 'ph'
        $basePh = if ($oPh.Count) { $oPh[0].Value } else { '' }
      }

      # determine parent key + dyn
      if ($key -and $parentMap.ContainsKey($key)) {
        $parentKey = $parentMap[$key]
        $parentDyn = if ($uid2dyn.ContainsKey($parentKey)) { $uid2dyn[$parentKey] } else { $null }
      } else {
        $parentKey = $null; $parentDyn = $null
      }

      # New logic, leaf + prefix
      $leaf = $basePh.TrimEnd('/').Split('/')[-1]
      if ($parentDyn) {
        if ($uid2ph.ContainsKey($parentKey)) {
          $parentFinalPh = $uid2ph[$parentKey]
        } else {
          $baseParentPath = [System.IO.Path]::GetDirectoryName($basePh).Replace('\','/')
          $parentFinalPh  = if ($baseParentPath.StartsWith("/")) { $baseParentPath } else { "/$baseParentPath" }
        }
        $prefix  = if ($parentFinalPh.StartsWith("/")) { $parentFinalPh } else { "/$parentFinalPh" }
        $finalPh = "$prefix/$leaf-0-$parentDyn"
      } else {
        $finalPh = "$leaf"
      }

      # record for deeper levels
      if ($key) { $uid2ph[$key] = $finalPh }

      # map placeholder to its own dyn
      $ph2dyn[$finalPh] = $dyn

      # rebuild parameters (unchanged)
      $oPr    = GetLocalAttr $r 'par'
      $old    = if ($oPr.Count) { $oPr[0].Value } else { '' }
      $parts  = if ($old) { $old.Split('&') } else { @() }
      $clean  = $parts | Where-Object { $_ -and -not $_.StartsWith('DynamicPlaceholderId=') } | Select-Object -Unique
      $cs     = ($clean -join '&').Trim('&')
      $newPar = if ($cs) { "DynamicPlaceholderId=$dyn&$cs" } else { "DynamicPlaceholderId=$dyn" }
      SetLocalAttr $r 'par' $newPar
      Write-Host "  Set par='$newPar' for uid='$key'"

      # set placeholder attribute
      SetLocalAttr $r 'ph' $finalPh
      Write-Host "  Set ph ='$finalPh' for uid='$key'"
    }
  }
  return $doc.ToString()
}

# 4) preserve root attributes (unchanged)
function PreserveRootAttrs($processedXml, $originalXml) {
  if ([string]::IsNullOrWhiteSpace($originalXml)) { return $processedXml }
  $orig = [System.Xml.Linq.XDocument]::Parse($originalXml)
  $new  = [System.Xml.Linq.XDocument]::Parse($processedXml)
  foreach ($a in $orig.Root.Attributes()) { $new.Root.SetAttributeValue($a.Name, $a.Value) }
  return $new.ToString()
}

# 5) apply to Sitecore item (unchanged)
Write-Host "Processing item: $Using:itemPath"
$item = Get-Item -Path $Using:itemPath -ErrorAction Stop
$ids  = [Sitecore.FieldIDs]

if ($processStandardValues) {
  $std     = $item.Template.StandardValues
  $sharedS = ProcessFull $std.Fields[$ids::LayoutField].Value
  SetField $std $ids::LayoutField $sharedS

  $mergedS = MergeXml $sharedS $std.Fields[$ids::FinalLayoutField].Value
  $procS   = ProcessFull $mergedS
  $withRt  = PreserveRootAttrs $procS $std.Fields[$ids::FinalLayoutField].Value
  SetField $std $ids::FinalLayoutField $withRt
}

if ($processPageLayout) {
  $page    = ProcessFull $item.Fields[$ids::LayoutField].Value
  SetField $item $ids::LayoutField $page

  $mergedP = MergeXml $page $item.Fields[$ids::FinalLayoutField].Value
  $procP   = ProcessFull $mergedP
  $withRtP = PreserveRootAttrs $procP $item.Fields[$ids::FinalLayoutField].Value
  SetField $item $ids::FinalLayoutField $withRtP
}

Write-Host "All done for $Using:itemPath"





        }

    Stop-ScriptSession -Session $session


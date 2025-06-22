param(
    [string]$itemPath = "/sitecore/content/Zont/Habitat/Home/target",
    [string]$Url = 'http://rssbplatform.dev.local/about-habitat'
)


[string]$result

# 1) Resolve the path to the child script (assumed in the same folder)
$scriptPath = Join-Path -Path $PSScriptRoot -ChildPath 'Get-PlaceholdersStructure-NEW.ps1'

if (-not (Test-Path -Path $scriptPath)) {
    Write-Error "Cannot find child script at: $scriptPath"
    exit 1
}

# 2) Invoke the child script and capture its output
try {
    $result = & $scriptPath -Url $Url
}
catch {
    Write-Error "Error invoking Get-PlaceholdersStructure-NEW.ps1:`n$($_.Exception.Message)"
    exit 1
}




Set-Location -Path $PSScriptRoot

$config = Get-Content -Raw -Path ../remoting/config.LOCAL.json | ConvertFrom-Json
Write-Output "ConnectionUri: $($config.connectionUri)"
Write-Output "Username     : $($config.username)"
Write-Output "SPE Remoting Secret : $($config.SPE_REMOTING_SECRET)"

Import-Module -Name SPE
$session = New-ScriptSession -ConnectionUri $config.connectionUri -Username $config.username -SharedSecret $config.SPE_REMOTING_SECRET
Invoke-RemoteScript -Session $session -ScriptBlock {


    function The-Function {
        Write-Output "From The-Function: $($using:itemPath)"
      }


      function Throw-ParseError {
        param([string]$msg)
        Write-Error "$msg"
        throw "Layout conversion failed: $msg"
      }

      function Get-LayoutXml {
        param([Sitecore.Data.Items.Item]$item)
        $f = $item.Fields["__Renderings"]
        if (-not $f) { Throw-ParseError "Missing __Renderings on '$($item.Paths.FullPath)'" }
        try {
          return [Sitecore.Layouts.LayoutDefinition]::Parse($f.Value)
        } catch {
          Throw-ParseError "Malformed XML on '$($item.Paths.FullPath)': $_"
        }
      }

      function Build-QueryString {
        param([Hashtable]$p)
        $sb = New-Object System.Text.StringBuilder
        foreach ($k in $p.Keys) { [void]$sb.Append("$k=$($p[$k])&") }
        return $sb.ToString().TrimEnd('&')
      }

    #––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
    # 1) Load & parse JSON once
    #   $jsonPath = [System.Web.Hosting.HostingEnvironment]::MapPath("~/App_Data/new.json")
    #   if (-not (Test-Path $jsonPath)) { Throw-ParseError "new.json not found at $jsonPath" }

      try {
        # $jsonTxt  = Get-Content $jsonPath -Raw -ErrorAction Stop
        Add-Type -AssemblyName "Newtonsoft.Json" -ErrorAction Stop
        $jsonRoot = [Newtonsoft.Json.Linq.JToken]::Parse($using:result)
      } catch {
        Throw-ParseError "Failed to parse new.json: $_"
      }

      # 2) Build flat maps via JSONPath
      $jsonNodeMap        = @{}  # uidNorm -> JToken
      $jsonPlaceholderMap = @{}  # placeholderPath -> uidNorm

      foreach ($node in $jsonRoot.SelectTokens('$..[?(@.uid && @.placeholder)]')) {
        $uidNorm = $node['uid'].ToString().Trim('{}').ToLowerInvariant()
        $phPath  = $node['placeholder'].ToString().Trim('/')
        $jsonNodeMap[$uidNorm]       = $node
        $jsonPlaceholderMap[$phPath] = $uidNorm
      }
      Write-Output "Indexed $($jsonNodeMap.Count) JSON nodes, $($jsonPlaceholderMap.Count) placeholder paths."

      #––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
      # 3) Load Sitecore layouts
      $item      = Get-Item -Path $using:itemPath -ErrorAction Stop
      $template  = $item.Template
      $stdVals   = $template.StandardValues

      $stdLayout  = Get-LayoutXml $stdVals
      $pageLayout = Get-LayoutXml $item

      $deviceId   = "{FE5D7FDF-89C0-4D99-9AA3-B5FBD009C9F3}"
      $stdDevice  = $stdLayout.GetDevice($deviceId);  if (-not $stdDevice)  { Throw-ParseError "Device $deviceId missing on std-values" }
      $pageDevice = $pageLayout.GetDevice($deviceId); if (-not $pageDevice) { Throw-ParseError "Device $deviceId missing on page" }

      #––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
      # 4) Enumerate renderings & assign DynamicPlaceholderId
      $allRenderings = @()
      $originMap     = @{}  # uidNorm -> "std"/"page"
      $dynMap        = @{}  # uidNorm -> int

      [int]$counter = 1
      foreach ($r in $stdDevice.Renderings + $pageDevice.Renderings) {
        if ($r -ne $null) {
          $uidNorm              = $r.UniqueId.ToString().Trim('{}').ToLowerInvariant()
          $allRenderings       += $r
          $originMap[$uidNorm]  = if ($stdDevice.Renderings -contains $r) { "std" } else { "page" }
          $dynMap[$uidNorm]     = $counter
          Write-Output "→ Assigned DynamicPlaceholderId=$counter to $uidNorm (`"$($r.Placeholder)`")"
          $counter++
        }
      }

      #––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
      # 5) Resolve placeholder purely from JSON maps
      function Resolve-Placeholder {
        param([Sitecore.Layouts.RenderingDefinition]$r)

        $uidNorm = $r.UniqueId.ToString().Trim('{}').ToLowerInvariant()
        if (-not $jsonNodeMap.ContainsKey($uidNorm)) {
          Throw-ParseError "UID $uidNorm not found in new.json; please add it for placeholder lookup."
        }

        $node   = $jsonNodeMap[$uidNorm]
        $full   = $node['placeholder'].ToString().Trim('/')
        $parts  = $full -split '/'

        $out = [System.Collections.Generic.List[string]]::new()
        $out.Add($parts[0])  # keep top-level

        for ($i = 1; $i -lt $parts.Length; $i++) {
          $prefix = ($parts[0..($i-1)] -join '/')
          if (-not $jsonPlaceholderMap.ContainsKey($prefix)) {
            Throw-ParseError "Prefix '$prefix' not in JSON placeholder map."
          }
          $parentUid = $jsonPlaceholderMap[$prefix]
          if (-not $dynMap.ContainsKey($parentUid)) {
            Throw-ParseError "No DynamicPlaceholderId for parent UID $parentUid."
          }
          $out.Add("$($parts[$i])-0-$($dynMap[$parentUid])")
        }

        return '/' + ($out -join '/')
      }

      #––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
      # 6) Apply to every rendering
      foreach ($r in $allRenderings) {
        $uidNorm = $r.UniqueId.ToString().Trim('{}').ToLowerInvariant()
        $dynId   = $dynMap[$uidNorm]

        # rebuild params
        $params = [ordered]@{}
        if ($r.Parameters) {
          $qp = [Sitecore.Web.WebUtil]::ParseUrlParameters("?" + $r.Parameters)
          foreach ($k in $qp.AllKeys) { $params[$k] = $qp[$k] }
        }
        $params['DynamicPlaceholderId'] = $dynId
        $r.Parameters                   = Build-QueryString $params

        # lookup + set placeholder
        $oldPh = $r.Placeholder
        $newPh = Resolve-Placeholder $r
        $r.Placeholder = $newPh
        Write-Output "   [$uidNorm] `"$oldPh`"  ➜  `"$newPh`""
      }

      #––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
      # 7) Write back into Sitecore
      $stdDevice.Renderings.Clear();  $pageDevice.Renderings.Clear()
      foreach ($r in $allRenderings) {
        $uidNorm = $r.UniqueId.ToString().Trim('{}').ToLowerInvariant()
        if ($originMap[$uidNorm] -eq 'std') { $stdDevice.Renderings.Add($r) }
        else                                 { $pageDevice.Renderings.Add($r) }
      }

      $stdVals.Editing.BeginEdit()
      $stdVals.Fields['__Renderings'].Value = $stdLayout.ToXml()
      $stdVals.Editing.EndEdit()

      $item.Editing.BeginEdit()
      $item.Fields['__Renderings'].Value = $pageLayout.ToXml()
      $item.Editing.EndEdit()

      Write-Output "Layout conversion complete for '$($item.Paths.FullPath)'"



}
Stop-ScriptSession -Session $session
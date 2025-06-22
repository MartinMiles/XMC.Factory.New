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
try {
    $output = Invoke-RemoteScript `
        -Session     $session `
        -Raw         `
        -ErrorAction Stop `
        -Verbose     `
        -ScriptBlock {

            function Throw-ParseError { param($m) Write-Error $m; throw $m }

            function Get-LayoutXml {
                param([Sitecore.Data.Items.Item]$itm)
                $fld = $itm.Fields['__Renderings']
                if (-not $fld)   { Throw-ParseError "Missing __Renderings on '$($itm.Paths.FullPath)'" }
                try   { [Sitecore.Layouts.LayoutDefinition]::Parse($fld.Value) }
                catch { Throw-ParseError "Bad XML on '$($itm.Paths.FullPath)': $_" }
            }

            function Build-QueryString {
                param([Hashtable]$h)
                $sb = [System.Text.StringBuilder]::new()
                foreach ($k in $h.Keys) { [void]$sb.Append("$k=$($h[$k])&") }
                return $sb.ToString().TrimEnd('&')
            }

            try {
                Write-Output "=== BEGIN conversion ==="

                Add-Type -AssemblyName 'Newtonsoft.Json' -ErrorAction Stop
                $root  = [Newtonsoft.Json.Linq.JToken]::Parse($using:jsonText)
                $nodes = $root.SelectTokens('$..[?(@.uid && @.placeholder)]')
                [int]$count = ($nodes | Measure-Object).Count
                Write-Output "Parsed JSON, $count nodes"

                $nodeMap = @{}; $phMap = @{}
                foreach ($n in $nodes) {
                    $u = $n.uid.ToString().Trim('{}').ToLowerInvariant()
                    $p = $n.placeholder.ToString().Trim('/')
                    $nodeMap[$u] = $n; $phMap[$p] = $u
                }

                $item    = Get-Item -Path $using:itemPath -ErrorAction Stop
                $stdVals = $item.Template.StandardValues
                $stdLd   = Get-LayoutXml $stdVals
                $pgLd    = Get-LayoutXml $item

                $devId   = '{FE5D7FDF-89C0-4D99-9AA3-B5FBD009C9F3}'
                $stdDev  = $stdLd.GetDevice($devId);  if (-not $stdDev) { Throw-ParseError "Std-values missing device" }
                $pgDev   = $pgLd.GetDevice($devId);   if (-not $pgDev)  { Throw-ParseError "Page missing device" }

                $all = @(); $orig=@{}; $dyn=@{}; [int]$i = 1
                foreach ($r in $stdDev.Renderings + $pgDev.Renderings) {
                    if ($r) {
                        $u = $r.UniqueId.ToString().Trim('{}').ToLowerInvariant()
                        $all += $r
                        $orig[$u] = if ($stdDev.Renderings -contains $r) {'std'} else {'page'}
                        $dyn[$u]  = $i
                        Write-Output "DPID=$i → $u"
                        $i++
                    }
                }

                function Resolve-Placeholder {
                    param([Sitecore.Layouts.RenderingDefinition]$r)
                    $u = $r.UniqueId.ToString().Trim('{}').ToLowerInvariant()
                    if (-not $nodeMap.ContainsKey($u)) { Throw-ParseError "UID $u missing JSON" }
                    $parts = $nodeMap[$u].placeholder.ToString().Trim('/').Split('/')
                    $out   = [System.Collections.Generic.List[string]]::new(); $out.Add($parts[0])
                    for ($j=1; $j -lt $parts.Length; $j++) {
                        $pref = ($parts[0..($j-1)] -join '/')
                        if (-not $phMap.ContainsKey($pref)) { Throw-ParseError "Prefix '$pref' missing" }
                        $pr  = $phMap[$pref]
                        $out.Add("$($parts[$j])-0-$($dyn[$pr])")
                    }
                    return '/' + ($out -join '/')
                }

                foreach ($r in $all) {
                    $u    = $r.UniqueId.ToString().Trim('{}').ToLowerInvariant()
                    $h    = [ordered]@{}
                    if ($r.Parameters) {
                        $qp = [Sitecore.Web.WebUtil]::ParseUrlParameters("?" + $r.Parameters)
                        foreach ($k in $qp.AllKeys) { $h[$k] = $qp[$k] }
                    }
                    $h['DynamicPlaceholderId'] = $dyn[$u]
                    $r.Parameters               = Build-QueryString $h

                    $old = $r.Placeholder
                    $new = Resolve-Placeholder $r
                    $r.Placeholder = $new
                    Write-Output "$($u): $old → $new"
                }

                [void]$stdVals.Editing.BeginEdit()
                $stdVals.Fields['__Renderings'].Value = $stdLd.ToXml()
                [void]$stdVals.Editing.EndEdit()
                [void]$item.Editing.BeginEdit()
                $item.Fields['__Renderings'].Value   = $pgLd.ToXml()
                [void]$item.Editing.EndEdit()

                Write-Output "=== END conversion ==="
            }
            catch {
                Write-Output "REMOTE EXCEPTION: $($_.Exception.Message)"
                Write-Output $_.Exception.StackTrace
            }
        }

    # echo remote logs
    Write-Output "=== REMOTE OUTPUT ==="
    $output | ForEach-Object { Write-Output $_ }
}
finally {
    Stop-ScriptSession -Session $session
}

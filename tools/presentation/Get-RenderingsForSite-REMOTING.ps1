# called from `1. Create-RenderingsBatch-REMOTING.ps1`

param(
    [string]$SiteRoot = ""
)

Set-Location -Path $PSScriptRoot

$config = Get-Content -Raw -Path ../remoting/config.LOCAL.json | ConvertFrom-Json
# Write-Output "ConnectionUri: $($config.connectionUri)"
# Write-Output "Username     : $($config.username)"
# Write-Output "SPE Remoting Secret : $($config.SPE_REMOTING_SECRET)"

# Write-Output "Get item fields of '$itemPath'..."
Import-Module -Name SPE
$session = New-ScriptSession -ConnectionUri $config.connectionUri -Username $config.username -SharedSecret $config.SPE_REMOTING_SECRET
Invoke-RemoteScript -Session $session -ScriptBlock {


[string] $DatabaseName   = "old"


# layout field IDs
$fieldShared = [Sitecore.FieldIDs]::LayoutField
$fieldFinal  = [Sitecore.FieldIDs]::FinalLayoutField

# get database and mount PSDrive if needed
$database = [Sitecore.Configuration.Factory]::GetDatabase($DatabaseName)
if (-not $database) {
    Write-Error "Database '$DatabaseName' not found"
    return
}
if (-not (Get-PSDrive -Name $DatabaseName -ErrorAction SilentlyContinue)) {
    New-PSDrive -Name $DatabaseName -PSProvider Sitecore -Root "\" | Out-Null
}

# compute root path
if ($Using:SiteRoot) {
    $rel      = $Using:SiteRoot -replace "^/sitecore", ""
    $rootPath = "$($DatabaseName):\$($rel.TrimStart('/'))"
}
else {
    $rootPath = "$($DatabaseName):\content"
}
Write-Host "Scanning under $rootPath"

# find items with layout xml
$pages = Get-ChildItem -Path $rootPath -Recurse | Where-Object {
    ($_.Fields[$fieldShared] -and $_.Fields[$fieldShared].Value) -or
    ($_.Fields[$fieldFinal]  -and $_.Fields[$fieldFinal].Value)
}
Write-Host "Found $($pages.Count) pages with layout data"

# Next.js component name converter
function Get-NextComponentName([string]$name) {
    $clean = -join ($name.ToCharArray() | ForEach-Object {
        if ($_ -match '[A-Za-z0-9]') { $_ } else { ' ' }
    })
    $words = $clean.Split(' ', [StringSplitOptions]::RemoveEmptyEntries)
    if ($words.Count -eq 0) { return '' }

    $first  = $words[0]; $mapped = ''; $i = 0
    while ($i -lt $first.Length -and $first[$i] -match '\d') {
        switch ($first[$i]) {
            '0'{ $mapped+='Zero'}; '1'{ $mapped+='One'}; '2'{ $mapped+='Two'}
            '3'{ $mapped+='Three'}; '4'{ $mapped+='Four'}; '5'{ $mapped+='Five'}
            '6'{ $mapped+='Six'};   '7'{ $mapped+='Seven'}; '8'{ $mapped+='Eight'}
            '9'{ $mapped+='Nine'}
        }
        $i++
    }
    if ($i -lt $first.Length) {
        $rest     = $first.Substring($i)
        $mapped  += $rest.Substring(0,1).ToUpper() + $rest.Substring(1)
    }
    elseif (-not $mapped) {
        $mapped  = $first.Substring(0,1).ToUpper() + $first.Substring(1)
    }
    for ($j=1; $j -lt $words.Count; $j++) {
        $w = $words[$j]
        if ($w -match '^\d+$') { $mapped += $w }
        else { $mapped += $w.Substring(0,1).ToUpper() + $w.Substring(1) }
    }
    return $mapped
}

# collect unique rendering definitions
$definitions = @{}

foreach ($page in $pages) {
    Write-Host "Page: $($page.Paths.FullPath)"
    $xmlBlobs = @()
    $sf = $page.Fields[$fieldShared]; if ($sf -and $sf.Value) { $xmlBlobs += $sf.Value }
    $ff = $page.Fields[$fieldFinal];  if ($ff -and $ff.Value) { $xmlBlobs += $ff.Value }

    foreach ($xml in $xmlBlobs) {
        $wrapped = "<root>$xml</root>"
        try { [xml]$doc = $wrapped }
        catch { continue }

        $nodes = $doc.SelectNodes("//d/r")
        foreach ($n in $nodes) {
            $attr = $n.Attributes | Where-Object { $_.LocalName -eq 'id' } | Select-Object -First 1
            if (-not $attr) { continue }
            try { $ridId = [Sitecore.Data.ID]$attr.Value } catch { continue }
            $key = $ridId.ToString()
            if (-not $definitions.ContainsKey($key)) {
                $def = $database.GetItem($ridId)
                if ($def) {
                    $definitions[$key] = [PSCustomObject]@{
                        RenderingName         = $def.Name
                        NextComponentName     = Get-NextComponentName $def.Name
                        RenderingPath         = $def.Paths.FullPath
                        RenderingDefinitionId = $key
                        Editable              = $def["Editable"]
                        ParametersTemplate    = $def["Parameters Template"]
                    }
                }
            }
        }
    }
}

# output JSON
$definitions.Values |
    Sort-Object RenderingName |
    ConvertTo-Json -Depth 4 |
    Write-Output



}
Stop-ScriptSession -Session $session
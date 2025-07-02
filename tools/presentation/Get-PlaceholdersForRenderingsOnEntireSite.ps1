[CmdletBinding()]
param(
    [Parameter()]
    [string]$databaseName = "old",

    [Parameter()]
    [string]$siteRoot = "/sitecore/content/Habitat"

)

Set-Location -Path $PSScriptRoot

# Load connection settings
$config = Get-Content -Raw -Path ../remoting/config.LOCAL.json | ConvertFrom-Json

# Import SPE and start a remote session
Import-Module -Name SPE
$session = New-ScriptSession -ConnectionUri $config.connectionUri `
                              -Username $config.username `
                              -SharedSecret $config.SPE_REMOTING_SECRET

Invoke-RemoteScript -Session $session -ScriptBlock {



# Configuration
$deviceName        = "Default"
$componentFieldId  = "{037FE404-DD19-4BF7-8E30-4DADF68B27B0}"

# Debugging
$debugRenderingId  = ''  # e.g. "{A85A0B65-D3B7-48B8-B362-F17AA3CA7DF1}"
$debugPlaceholder  = ''  # e.g. "col-narrow-2"

# 1) Mount database drive if needed
if (-not (Get-PSDrive -Name $Using:databaseName -ErrorAction SilentlyContinue)) {
    New-PSDrive -Name $Using:databaseName -PSProvider Sitecore -Root "/" -Database $Using:databaseName | Out-Null
}

# 2) Get database, root item and device
$database = [Sitecore.Configuration.Factory]::GetDatabase($Using:databaseName)
$rootItem = $database.GetItem($Using:siteRoot)
if (-not $rootItem) { throw "Site root not found." }

$device = $database.Resources.Devices.GetAll() |
          Where-Object { $_.Name -eq $deviceName }
if (-not $device) { throw "Device '$deviceName' not found." }

# 3) Build placeholder key to definition-ID map
$fieldId        = [Sitecore.Data.ID]::Parse("{7256BDAB-1FD2-49DD-B205-CB4873D2917C}")
$templateId     = [Sitecore.Data.ID]::Parse("{5C547D4E-7111-4995-95B0-6B561751BF2E}")
$phSettingsRoot = $database.GetItem("/sitecore/layout/Placeholder Settings")
if (-not $phSettingsRoot) { throw "Placeholder Settings folder not found." }

$allPhSettings  = @($phSettingsRoot.Axes.GetDescendants())
$placeholderMap = @{}
foreach ($ps in $allPhSettings) {
    if ($ps.TemplateID -eq $templateId) {
        $keyVal = $ps.Fields[$fieldId].Value
        if ($keyVal -and -not $placeholderMap.ContainsKey($keyVal)) {
            $placeholderMap[$keyVal] = $ps.ID.ToString()
        }
    }
}

# 4) Gather items that have either shared or final layout
$itemsWithPresentation = $rootItem.Axes.GetDescendants() |
    Where-Object {
        $_["__Renderings"] -or $_["__Final Renderings"] `
     -or ($_.__StandardValues -and (
            $_.__StandardValues["__Renderings"] `
         -or $_.__StandardValues["__Final Renderings"]))
    }

# 5) Initialize maps
$renderingMap   = @{}
$renderingCache = @{}

foreach ($item in $itemsWithPresentation) {
    try {
        # get shared and final renderings
        $shared     = $item.Visualization.GetRenderings($device, $false)
        $final      = $item.Visualization.GetRenderings($device, $true)
        $renderings = @()
        if ($shared) { $renderings += $shared }
        if ($final)  { $renderings += $final }
        if (-not $renderings) { continue }

        # collect all placeholder paths
        $placeholderPaths = $renderings |
            Where-Object { $_.Placeholder } |
            ForEach-Object { $_.Placeholder.TrimStart("/") }

        foreach ($ref in $renderings) {
            $rid    = $ref.RenderingID.ToString()

            # a) cache rendering metadata
            if (-not $renderingCache.ContainsKey($rid)) {
                $rItem = $database.GetItem($ref.RenderingID)
                if (-not $rItem) { continue }
                $comp = ""
                if ($rItem.Fields[$componentFieldId].HasValue) {
                    $comp = $rItem.Fields[$componentFieldId].Value
                }
                $renderingCache[$rid] = @{
                    RenderingPath = $rItem.Paths.FullPath
                    ComponentName = $comp
                }
            }

            $meta   = $renderingCache[$rid]
            $prefix = $ref.Placeholder.TrimStart("/")

            # b) determine declared child placeholders
            $declaredPlaceholders = $placeholderPaths |
                Where-Object {
                    ($_ -like "$prefix/*") -or ($_ -like "$prefix-*")
                } |
                ForEach-Object {
                    if ($_ -like "$prefix/*") {
                        # slash case: take the segment after the slash
                        $_.Substring($prefix.Length + 1).Split("/")[0]
                    }
                    else {
                        # hyphen case: keep the full placeholder name
                        $_
                    }
                } |
                Sort-Object -Unique |
                ForEach-Object {
                    # strip any dynamic-ID suffix if present
                    if ($_ -match '^(.+?)-\{[0-9A-Fa-f-]+\}-\d+$') {
                        $matches[1]
                    }
                    else {
                        $_
                    }
                }

            # c) ensure map entry
            if (-not $renderingMap.ContainsKey($rid)) {
                $renderingMap[$rid] = [ordered]@{
                    RenderingID   = $rid
                    ComponentName = $meta.ComponentName
                    RenderingPath = $meta.RenderingPath
                    Placeholders  = @()
                }
            }

            # d) populate placeholders
            foreach ($ph in $declaredPlaceholders) {
                if (-not ($renderingMap[$rid].Placeholders -contains $ph)) {
                    $renderingMap[$rid].Placeholders += $ph
                }
            }
        }
    }
    catch {
        throw "Error on $($item.Paths.FullPath): $_"
    }
}

# 6) Convert placeholder arrays to pipe-separated definition-IDs
foreach ($entry in $renderingMap.Values) {
    $ids = @()
    foreach ($key in $entry.Placeholders) {
        if ($placeholderMap.ContainsKey($key)) {
            $ids += $placeholderMap[$key]
        }
    }
    $entry.Placeholders = $ids -join "|"
}

# 7) Filter out empty placeholders and emit JSON
$filteredOutput = $renderingMap.Values | Where-Object { $_.Placeholders }
($filteredOutput | ConvertTo-Json -Depth 10) -replace "\s+", ""



}

# Tear down session
Stop-ScriptSession -Session $session

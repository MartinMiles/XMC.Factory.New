###
#   Usage: .\Set-DatasourceField.ps1 -PageTemplate "/sitecore/templates/Project/Zont/Habitat/Page Types/Home" -RenderingDefinition "{A47C8288-7D4C-45FF-B75F-4AEDBF58A02D}" -Datasource "{725A45E3-E307-4B95-B363-2782B059DF06}"
###
param(
    [string]$PageTemplate,
    [string]$RenderingDefinition,
    [string]$Datasource,
    [string]$Database = "master"
)

Set-Location -Path $PSScriptRoot

$config = Get-Content -Raw -Path ../remoting/config.LOCAL.json | ConvertFrom-Json
Import-Module -Name SPE
$session = New-ScriptSession -ConnectionUri $config.connectionUri -Username $config.username -SharedSecret $config.SPE_REMOTING_SECRET
Invoke-RemoteScript -Session $session -ScriptBlock {






function Resolve-Item($identifier, $dbName = "master") {
    $db = [Sitecore.Data.Database]::GetDatabase($dbName)
    if ($identifier -match '^{[0-9A-Fa-f\-]+}$') { $db.GetItem($identifier) } else { $db.GetItem($identifier) }
}

function Update-Renderings-XmlField($item, $renderingId, $Datasource, $fieldName) {
    $changed = $false
    $matches = 0
    $updatedRenders = @()

    $layoutXml = $item[$fieldName]
    if (-not $layoutXml) { return @{ Changed = $changed; Matches = $matches; UpdatedRenderings = $updatedRenders } }

    $xml = New-Object System.Xml.XmlDocument
    $xml.PreserveWhitespace = $true
    $xml.LoadXml($layoutXml)

    $renderingNodes = $xml.SelectNodes("//r[@id='$renderingId']")
    foreach ($rNode in $renderingNodes) {
        $matches++
        if ($rNode.Attributes["ds"]) {
            $prevDS = $rNode.Attributes["ds"].Value
        } else {
            $prevDS = ""
        }
        if ($prevDS -ne $Datasource) {
            if ($rNode.Attributes["ds"]) {
                $rNode.Attributes["ds"].Value = $Datasource
            } else {
                $dsAttr = $xml.CreateAttribute("ds")
                $dsAttr.Value = $Datasource
                $rNode.Attributes.Append($dsAttr) | Out-Null
            }
            $changed = $true
            $updatedRenders += [PSCustomObject]@{
                ItemPath = $item.Paths.Path
                Field = $fieldName
                RenderingId = $renderingId
                OldDatasource = $prevDS
                NewDatasource = $Datasource
            }
        }
    }

    if ($changed) {
        $item.Editing.BeginEdit()
        $item[$fieldName] = $xml.OuterXml
        $item.Editing.EndEdit()
    }

    return @{ Changed = $changed; Matches = $matches; UpdatedRenderings = $updatedRenders }
}

function Format-GuidTable ($rows) {
    $rows | Select-Object `
        @{Name="Field";Expression={ $_.Field }}, `
        @{Name="RenderingId";Expression={ ($_.RenderingId.ToString()).PadRight(38) }}, `
        @{Name="OldDatasource";Expression={ ($_.OldDatasource.ToString()).PadRight(38) }}, `
        @{Name="NewDatasource";Expression={ ($_.NewDatasource.ToString()).PadRight(38) }} |
    Format-Table -AutoSize | Out-String
}

# Resolve template
$template = Resolve-Item $Using:PageTemplate $Using:Database
if (-not $template) { Write-Output "Template '$Using:PageTemplate' not found in '$Using:Database' database."; exit 1 }

$stdValues = @($template.GetChildren() | Where-Object { $_.Name -eq "__Standard Values" })
if (-not $stdValues -or $stdValues.Count -eq 0) { Write-Output "No standard values found for this template." }

$renderingItem = Resolve-Item $Using:RenderingDefinition $Using:Database
if (-not $renderingItem) { Write-Output "Rendering definition '$Using:RenderingDefinition' not found in '$Using:Database' database."; exit 1 }
$renderingId = $renderingItem.ID.ToString().ToUpperInvariant()

# Process Standard Values
$totalStdValMatches = 0
$totalStdValUpdates = 0
$updatedStdDetails = @()
foreach ($sv in $stdValues) {
    $itemChanged = $false
    $itemMatches = 0
    foreach ($field in @("__Renderings", "__Final Renderings")) {
        $res = Update-Renderings-XmlField $sv $renderingId $Using:Datasource $field
        $itemMatches += $res.Matches
        if ($res.Changed) {
            $itemChanged = $true
            $totalStdValUpdates++
            foreach ($ur in $res.UpdatedRenderings) {
                $updatedStdDetails += [PSCustomObject]@{
                    ItemPath = $sv.Paths.Path
                    Field = $ur.Field
                    RenderingId = $ur.RenderingId
                    OldDatasource = $ur.OldDatasource
                    NewDatasource = $ur.NewDatasource
                }
            }
        }
    }
    $totalStdValMatches += $itemMatches
}

# Process Content Items
$providerPath = $Using:Database + ":"
$allItems = Get-ChildItem -Path $providerPath -Recurse | Where-Object { $_.TemplateID -eq $template.ID }

$totalContentMatches = 0
$totalContentUpdates = 0
$updatedContentDetails = @()
foreach ($item in $allItems) {
    $itemChanged = $false
    $itemMatches = 0
    foreach ($field in @("__Renderings", "__Final Renderings")) {
        $res = Update-Renderings-XmlField $item $renderingId $Using:Datasource $field
        $itemMatches += $res.Matches
        if ($res.Changed) {
            $itemChanged = $true
            $totalContentUpdates++
            foreach ($ur in $res.UpdatedRenderings) {
                $updatedContentDetails += [PSCustomObject]@{
                    ItemPath = $item.Paths.Path
                    Field = $ur.Field
                    RenderingId = $ur.RenderingId
                    OldDatasource = $ur.OldDatasource
                    NewDatasource = $ur.NewDatasource
                }
            }
        }
    }
    $totalContentMatches += $itemMatches
}

Write-Output ""
Write-Output "Summary of changes:"
if (($totalStdValMatches -eq 0) -and ($totalContentMatches -eq 0)) {
    Write-Output "No matching renderings found in standard values or any content items. No changes made."
} else {
    if ($totalStdValUpdates -gt 0) {
        Write-Output "$totalStdValUpdates field(s) UPDATED in standard values."
        $updatedStdDetails | Group-Object ItemPath | ForEach-Object {
            Write-Output ""
            Write-Output ("ItemPath: " + $_.Name)
            Format-GuidTable $_.Group | Write-Output
        }
    }
    if (($totalStdValMatches -gt 0) -and ($totalStdValUpdates -eq 0)) {
        Write-Output "Matching renderings found in standard values, but all already had the desired datasource. No changes made in standard values."
    }
    if ($totalContentUpdates -gt 0) {
        Write-Output "$totalContentUpdates field(s) UPDATED in content items."
        $updatedContentDetails | Group-Object ItemPath | ForEach-Object {
            Write-Output ""
            Write-Output ("ItemPath: " + $_.Name)
            Format-GuidTable $_.Group | Write-Output
        }
    }
    if (($totalContentMatches -gt 0) -and ($totalContentUpdates -eq 0)) {
        Write-Output "Matching renderings found in content items, but all already had the desired datasource. No changes made in content items."
    }
}
Write-Output ""
Write-Output "Total fields changed: $($totalStdValUpdates + $totalContentUpdates)"





}
Stop-ScriptSession -Session $session
# TODO: Validate and de-dupe logic between:
#   Get-Placeholders-ForSite-InRuntime.ps1
# and
#   Get-PlaceholdersForRenderingsOnEntireSite.ps1

param(
    [Parameter(Mandatory=$false)][string]$SiteRoot = "/sitecore/content/Habitat",
    [Parameter(Mandatory=$false)][string]$Database = "old"
)

Set-Location -Path $PSScriptRoot


# 0) Load renderings data from JSON script
$renderingsScript = Join-Path $PSScriptRoot "Get-RenderingsForSite-REMOTING.ps1"
if (-not (Test-Path $renderingsScript)) {
    Write-Error "Renderings script not found at '$renderingsScript'"
    exit 1
}

$rawLines = & $renderingsScript -SiteRoot $SiteRoot
if (-not $rawLines) {
    Write-Error "Renderings script returned no output"
    exit 1
}

$jsonText = $rawLines -join "`n"
try {
    $rows = $jsonText | ConvertFrom-Json -ErrorAction Stop
}
catch {
    Write-Error "Failed to parse JSON from renderings script: $_"
    exit 1
}

Write-Output "Renderings Identified : $($rows.Count)"


# 1) Load placeholder hierarchy JSON obtained in runtime
$renderingsScript = Join-Path $PSScriptRoot "Get-Placeholders-ForSite-InRuntime.ps1"
if (-not (Test-Path $renderingsScript)) {
    Write-Error "Renderings script not found at '$renderingsScript'"
    exit 1
}

$rawLines = & $renderingsScript -SitemapUrl "http://rssbplatform.dev.local/sitemap.xml"
if (-not $rawLines) {
    Write-Error "Renderings script returned no output"
    exit 1
}

$jsonText = $rawLines -join "`n"
try {
    $sitemapRenderings = $jsonText | ConvertFrom-Json -ErrorAction Stop
}
catch {
    Write-Error "Failed to parse JSON from renderings script: $_"
    exit 1
}

$outputArray = @{}
foreach ($renderingID in $sitemapRenderings.PSObject.Properties.Name) {
    $placeholders = $sitemapRenderings.$renderingID
    if (![string]::IsNullOrWhiteSpace($placeholders)) {
        $outputArray[$renderingID] = $placeholders
    }
}

Write-Output "Renderings with placeholders: $($outputArray.Count)"


# 2) Load placeholders data (can we remove this at all - ??)
$phScript = Join-Path $PSScriptRoot "Get-PlaceholdersForRenderingsOnEntireSite.ps1"
if (-not (Test-Path $phScript)) {
    Write-Error "Placeholder script not found at '$phScript'"
    exit 1
}

$rawPh = & $phScript -SiteRoot $SiteRoot -databaseName $Database
if (-not $rawPh) {
    Write-Error "Placeholder script returned no output"
    exit 1
}

$jsonPh = if ($rawPh -is [string]) { $rawPh } else { $rawPh -join "`n" }
try {
    $placeholdersArray = $jsonPh | ConvertFrom-Json -ErrorAction Stop
}
catch {
    Write-Error "Failed to parse JSON from placeholder script: $_"
    exit 1
}


# 3) Build placeholders map
$placeholderMap = @{}
foreach ($e in $placeholdersArray) {
    if (-not $e.RenderingID) { continue }

    $key = $e.RenderingID.Trim('{}').ToLowerInvariant()
    if ($key) {
        $placeholderMap[$key] = $outputArray[$e.RenderingID]
    }
}


# 4) Build $renderings collection
$renderings = foreach ($r in $rows) {
    $idKey = $r.RenderingDefinitionId.Trim('{}').ToLowerInvariant()
    $ph    = if ($placeholderMap.ContainsKey($idKey)) { $placeholderMap[$idKey] }

    [PSCustomObject]@{
        RenderingName             = $r.RenderingName
        NextComponentName         = $r.NextComponentName
        RenderingDefinitionId     = $r.RenderingDefinitionId
        OriginalPath              = $r.RenderingPath
        DatasourceLocation        = $r.DatasourceLocation
        DatasourceTemplate        = $r.DatasourceTemplate
        Editable                  = $r.Editable
        ParametersTemplate        = $r.ParametersTemplate
        LayoutServicePlaceholders = $ph
    }
}

Write-Output "DEBUG: Built renderings count: $($renderings.Count)"


# 5) Load and validate config
$configFile = Join-Path $PSScriptRoot "../remoting/config.LOCAL.json"
try {
    $config = Get-Content -Raw -Path $configFile | ConvertFrom-Json
}
catch {
    Write-Error "Could not load config at '$configFile': $_"
    exit 1
}

foreach ($p in 'connectionUri','username','SPE_REMOTING_SECRET') {
    if (-not $config.$p) {
        Write-Error "Missing '$p' in config.LOCAL.json"
        exit 1
    }
}

# 6) Establish SPE session
Import-Module SPE -ErrorAction Stop
try {
    $session = New-ScriptSession `
        -ConnectionUri $config.connectionUri `
        -Username      $config.username `
        -SharedSecret  $config.SPE_REMOTING_SECRET `
        -ErrorAction   Stop
    Write-Output "SPE session established.`n"
}
catch {
    Write-Error "Failed to establish SPE session: $($_.Exception.Message)"
    exit 1
}


# 7) Define remote script block that uses $Using:renderings
$remoteScript = {
    $ErrorActionPreference = 'Stop'
    $remoteErrors = @()

    # bring in local array
    $renderingsLocal = $Using:renderings
    Write-Output "DEBUG: Remote received renderings count: $($renderingsLocal.Count)"

    # ensure master drive
    if (-not (Get-PSDrive -Name master -ErrorAction SilentlyContinue)) {
        New-PSDrive -Name master -PSProvider Sitecore -Root '/' -Database 'master' | Out-Null
    }
    $db = [Sitecore.Configuration.Factory]::GetDatabase('master')
    if (-not $db) { throw "/sitecore/master database not found." }

    # template and field IDs
    $tpls = @{
        layout = [Sitecore.Data.TemplateID]::new([Sitecore.Data.ID]::Parse('{7EE0975B-0698-493E-B3A2-0B2EF33D0522}'))
        json   = [Sitecore.Data.TemplateID]::new([Sitecore.Data.ID]::Parse('{04646A89-996F-4EE7-878A-FFDBF1F0EF0D}'))
        pFold  = [Sitecore.Data.TemplateID]::new([Sitecore.Data.ID]::Parse('{0437FEE2-44C9-46A6-ABE9-28858D9FEE8C}'))
        pTemp  = [Sitecore.Data.TemplateID]::new([Sitecore.Data.ID]::Parse('{AB86861A-6030-46C5-B394-E8F99E8B87DB}'))
    }
    $fields = @{
        base         = [Sitecore.Data.ID]::Parse('{12C33F3F-86C5-43A5-AEB4-5598CEC45116}')
        placeholders = [Sitecore.Data.ID]::Parse('{069A8361-B1CD-437C-8C32-A3BE78941446}')
    }
    $root = $db.GetItem('/sitecore/layout/Renderings')
    if (-not $root) { throw "/sitecore/layout/Renderings not found." }

    foreach ($r in $renderingsLocal) {
        try {
            $raw   = $r.OriginalPath
            Write-Output "Processing path '$raw'"
            $parts = $raw.TrimStart('/').Split('/')
            if ($parts.Length -lt 6) {
                Write-Warning "Skipping path (too few segments): '$raw'"
                continue
            }

            $cat  = $parts[3]
            $mod  = $parts[4]
            $rest = $parts[5..($parts.Length - 1)]
            $target = @('sitecore','layout','Renderings',$cat,'Zont',$mod) + $rest

            # build folders
            $parent = $root
            foreach ($seg in $target[3..($target.Length - 2)]) {
                $child = $parent.Children[$seg]
                if (-not $child) { $child = $parent.Add($seg,$tpls.layout) }
                $parent = $child
            }

            # rendering item
            $name = $target[-1]
            $item = $parent.Children[$name]
            if (-not $item) {
                $item = $parent.Add($name,$tpls.json,[Sitecore.Data.ID]::Parse($r.RenderingDefinitionId))
            }

            # parameter template folder and item
            $node = $db.GetItem('/sitecore/templates')
            foreach ($seg in @($cat,'Zont','Habitat',$mod,'Rendering Parameters')) {
                if ($node.Children[$seg]) {
                    $node = $node.Children[$seg]
                }
                else {
                    $node = $node.Add($seg,$tpls.pFold)
                }
            }
            $pItem = $node.Children[$name]
            if (-not $pItem) {
                $pItem = $node.Add($name,$tpls.pTemp)
            }

            # set base templates
            $baseIds = @(
                '{5C74E985-E055-43FF-B28C-DB6C6A6450A2}',
                '{44A022DB-56D3-419A-B43B-E27E4D8E9C41}',
                '{3DB3EB10-F8D0-4CC9-BE26-18CE7B139EC8}',
                '{4247AAD4-EBDE-4994-998F-E067A51B1FE4}'
            )
            if ($r.ParametersTemplate) { $baseIds += $r.ParametersTemplate }
            $pItem.Editing.BeginEdit()
            $pItem.Fields[$fields.base].Value = ($baseIds -join '|')
            $pItem.Editing.EndEdit()

            if ($item.Fields['Parameters Template']) {
                $item.Editing.BeginEdit()
                $item.Fields['Parameters Template'].Value = $pItem.ID.ToString()
                $item.Editing.EndEdit()
            }

            # update component fields
            $item.Editing.BeginEdit()
            $item['componentName']           = $r.NextComponentName
            $item['Datasource Location']     = $r.DatasourceLocation
            $item['Datasource Template']     = $r.DatasourceTemplate
            $item['Editable']                = $r.Editable
            $item['Enable Datasource Query'] = '1'
            $item.Editing.EndEdit()

            function Get-PlaceholderGuid {
                param(
                    [string] $PlaceholderKey
                )

                $db = [Sitecore.Configuration.Factory]::GetDatabase("master")
                if (-not $db) { throw "ERROR: Could not load the 'master' database." }

                $fieldId    = [Sitecore.Data.ID]::Parse("{7256BDAB-1FD2-49DD-B205-CB4873D2917C}")
                $templateId = [Sitecore.Data.ID]::Parse("{5C547D4E-7111-4995-95B0-6B561751BF2E}")
                $rootItem = $db.GetItem("/sitecore/layout/Placeholder Settings")
                if (-not $rootItem) { throw "ERROR: '/sitecore/layout/Placeholder Settings' not found." }

                $allDesc = @($rootItem.Axes.GetDescendants())

                $matches = @(
                    $allDesc |
                    Where-Object {
                        $_.TemplateID -eq $templateId -and
                        $_.Fields[$fieldId].Value -eq $PlaceholderKey
                    }
                )

                switch ($matches.Count) {
                    1 { return $matches[0].ID.ToString() }
                    0 { return "" }  # or return $null if you prefer
                    default {
                        # Optional: log ambiguous matches, but return first
                        return $matches[0].ID.ToString()
                    }
                }
            }

            if ($r.LayoutServicePlaceholders) {
                $guidList = @()

                foreach ($ph in $r.LayoutServicePlaceholders -split "\|") {
                    $guid = Get-PlaceholderGuid -PlaceholderKey $ph.Trim()
                    if ($guid) {
                        $guidList += $guid
                    }
                }

                if ($guidList.Count -gt 0) {
                    $item.Editing.BeginEdit()
                    $item.Fields[$fields.placeholders].Value = $guidList -join "|"
                    $item.Editing.EndEdit()
                }
            }
        }
        catch {
            $remoteErrors += $_.Exception.ToString()
        }
    }

    if ($remoteErrors.Count) {
        Write-Output '===REMOTE ERRORS START==='
        $remoteErrors | ForEach-Object { Write-Output $_ }
        Write-Output '===REMOTE ERRORS END==='
    }
}

# 8) Invoke remote script
Invoke-RemoteScript `
    -Session     $session `
    -ScriptBlock $remoteScript

# 9) Tear down
Stop-ScriptSession -Session $session

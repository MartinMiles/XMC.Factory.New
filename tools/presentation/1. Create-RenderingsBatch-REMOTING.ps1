<#
.SYNOPSIS
    Build dynamic renderings from CSV + placeholders,
    then push them via SPE remoting—with path-segment guards and inline error reporting.

.PARAMETER CsvPath
    Path to your CSV file. Default: .\SQL\GetRenderingsInfoForSite.csv

.PARAMETER SiteRoot
    Sitecore content root IN OLD (!!!) DATABASE for placeholder script.
    Default: "/sitecore/content/Habitat"

.PARAMETER Database
    Name of the source Sitecore database. Default: "old"
#>
param(
    [Parameter(Mandatory=$false)][string]$CsvPath    = ".\SQL\GetRenderingsInfoForSite.csv",
    [Parameter(Mandatory=$false)][string]$SiteRoot  = "/sitecore/content/Habitat",
    [Parameter(Mandatory=$false)][string]$Database  = "old"
)

Set-Location -Path $PSScriptRoot

# 1) Load CSV
try {
    $rows = Import-Csv -Path $CsvPath -ErrorAction Stop
}
catch {
    Write-Error "Failed to read CSV at '$CsvPath': $_"
    exit 1
}

# 2) Invoke placeholder script and parse JSON if needed
$placeholderScript = Join-Path $PSScriptRoot "Get-PlaceholdersForRenderingsOnEntireSite.ps1"
if (-not (Test-Path $placeholderScript)) {
    Write-Error "Placeholder script not found at '$placeholderScript'"
    exit 1
}

try {
    $rawOutput = & $placeholderScript -SiteRoot $SiteRoot -Database $Database
}
catch {
    Write-Error "Failed to invoke placeholder script: $_"
    exit 1
}

# If output is JSON text, convert it
if ($rawOutput -is [string]) {
    try {
        $placeholdersArray = $rawOutput | ConvertFrom-Json -ErrorAction Stop
    }
    catch {
        Write-Error "Placeholder script output is not valid JSON: $_"
        exit 1
    }
}
else {
    # Already objects
    $placeholdersArray = $rawOutput
}

if (-not $placeholdersArray -or $placeholdersArray.Count -eq 0) {
    Write-Warning "Placeholder script returned no entries."
}

# 3) Build placeholders map with null-checks
$placeholderMap = @{}
foreach ($e in $placeholdersArray) {
    if (-not $e.RenderingID) {
        Write-Warning "Skipping entry with missing RenderingID: $($e | Out-String)"
        continue
    }
    $k = $e.RenderingID.Trim('{}').ToLowerInvariant()
    if (-not $k) {
        Write-Warning "Trimmed RenderingID is empty for entry: $($e | Out-String)"
        continue
    }
    $placeholderMap[$k] = $e.Placeholders
}

# 4) Build $renderings
$renderings = foreach ($r in $rows) {
    $idKey = ($r.RenderingDefinitionId.Trim('{}')).ToLowerInvariant()
    $ph    = if ($placeholderMap.ContainsKey($idKey)) {
                 $placeholderMap[$idKey]
             } else {
                #  Write-Warning "No placeholders for RenderingDefinitionId $($r.RenderingDefinitionId)"
                #  ""
             }

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

# 6) Load/validate config
$configFile = Join-Path $PSScriptRoot "../remoting/config.LOCAL.json"
try {
    $config = Get-Content -Raw -Path $configFile | ConvertFrom-Json
}
catch {
    Write-Error "Could not load config at '$configFile': $_"
    exit 1
}
$config | Format-List *
foreach ($p in 'connectionUri','username','SPE_REMOTING_SECRET') {
    if (-not $config.$p) {
        Write-Error "Missing '$p' in config.LOCAL.json"
        exit 1
    }
}

# 7) SPE session
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

# 8) Remote push with path guards
Invoke-RemoteScript -Session $session -ScriptBlock {
    $ErrorActionPreference = 'Stop'
    $remoteErrors = @()

    try {
        if (-not (Get-PSDrive -Name master -ErrorAction SilentlyContinue)) {
            New-PSDrive -Name master -PSProvider Sitecore -Root '/' -Database 'master' | Out-Null
        }
        $db = [Sitecore.Configuration.Factory]::GetDatabase('master')
        if (-not $db) { throw '/sitecore/master database not found.' }

        # IDs
        $tpls = @{
            layout  = [Sitecore.Data.TemplateID]::new([Sitecore.Data.ID]::Parse('{7EE0975B-0698-493E-B3A2-0B2EF33D0522}'))
            json    = [Sitecore.Data.TemplateID]::new([Sitecore.Data.ID]::Parse('{04646A89-996F-4EE7-878A-FFDBF1F0EF0D}'))
            pFold   = [Sitecore.Data.TemplateID]::new([Sitecore.Data.ID]::Parse('{0437FEE2-44C9-46A6-ABE9-28858D9FEE8C}'))
            pTemp   = [Sitecore.Data.TemplateID]::new([Sitecore.Data.ID]::Parse('{AB86861A-6030-46C5-B394-E8F99E8B87DB}'))
        }
        $fields = @{
            base         = [Sitecore.Data.ID]::Parse('{12C33F3F-86C5-43A5-AEB4-5598CEC45116}')
            placeholders = [Sitecore.Data.ID]::Parse('{069A8361-B1CD-437C-8C32-A3BE78941446}')
        }

        $root = $db.GetItem('/sitecore/layout/Renderings')
        if (-not $root) { throw '/sitecore/layout/Renderings not found.' }

        foreach ($r in $Using:renderings) {
            try {
                $raw = $r.OriginalPath
                Write-Output "DEBUG: Processing path '$raw'"
                $parts = $raw.TrimStart('/').Split('/')
                Write-Output "DEBUG: Segment count = $($parts.Length)"
                if ($parts.Length -lt 6) {
                    Write-Warning "Skipping path (too few segments): '$raw'"
                    continue
                }

                $cat    = $parts[3]
                $mod    = $parts[4]
                $rest   = $parts[5..($parts.Length-1)]
                $target = @('sitecore','layout','Renderings',$cat,'Zont',$mod)+$rest

                # build folders
                $parent = $root
                foreach ($seg in $target[3..($target.Length-2)]) {
                    $child = $parent.Children[$seg]
                    if (-not $child) { $child = $parent.Add($seg, $tpls.layout) }
                    $parent = $child
                }

                # rendering item
                $name = $target[-1]
                $item = $parent.Children[$name]
                if (-not $item) {
                    $item = $parent.Add($name, $tpls.json, [Sitecore.Data.ID]::Parse($r.RenderingDefinitionId))
                }

                # parameter template
                $node = $db.GetItem('/sitecore/templates')
                foreach ($seg in @($cat,'Zont','Habitat',$mod,'Rendering Parameters')) {
                    if (-not $node.Children[$seg]) { $node = $node.Add($seg, $tpls.pFold) }
                    else { $node = $node.Children[$seg] }
                }
                $pItem = $node.Children[$name]
                if (-not $pItem) { $pItem = $node.Add($name, $tpls.pTemp) }

                # set base templates
                $baseIds = @('{5C74E985-E055-43FF-B28C-DB6C6A6450A2}',
                             '{44A022DB-56D3-419A-B43B-E27E4D8E9C41}',
                             '{3DB3EB10-F8D0-4CC9-BE26-18CE7B139EC8}',
                             '{4247AAD4-EBDE-4994-998F-E067A51B1FE4}')
                if ($r.ParametersTemplate) { $baseIds += $r.ParametersTemplate }
                $joined = ($baseIds -join '|')

                $pItem.Editing.BeginEdit()
                $pItem.Fields[$fields.base].Value = $joined
                $pItem.Editing.EndEdit()

                if ($item.Fields['Parameters Template']) {
                    $item.Editing.BeginEdit()
                    $item.Fields['Parameters Template'].Value = $pItem.ID.ToString()
                    $item.Editing.EndEdit()
                }

                # update fields
                $item.Editing.BeginEdit()
                $item['componentName']           = $r.NextComponentName
                $item['Datasource Location']     = $r.DatasourceLocation
                $item['Datasource Template']     = $r.DatasourceTemplate
                $item['Editable']                = $r.Editable
                $item['Enable Datasource Query'] = '1'
                $item.Editing.EndEdit()

                # write placeholders
                if ($r.LayoutServicePlaceholders) {
                    $item.Editing.BeginEdit()
                    $item.Fields[$fields.placeholders].Value = $r.LayoutServicePlaceholders
                    $item.Editing.EndEdit()
                    Write-Output "  Set placeholders on $($item.Paths.FullPath)"
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
    catch {
        Write-Output '===REMOTE TOP-LEVEL ERROR==='
        Write-Output $_.Exception.ToString()
        Write-Output '===END==='
    }
} # -Verbose

# 9) Tear down
Stop-ScriptSession -Session $session
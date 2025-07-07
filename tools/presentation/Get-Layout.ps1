param(
    [string]$itemPath
)

Set-Location -Path $PSScriptRoot

$config = Get-Content -Raw -Path ../remoting/config.LOCAL.json | ConvertFrom-Json

Import-Module SPE
$session = New-ScriptSession `
    -ConnectionUri $config.connectionUri `
    -Username      $config.username `
    -SharedSecret  $config.SPE_REMOTING_SECRET

Invoke-RemoteScript -Session $session -ScriptBlock {
    # 1. ensure master drive
    if (-not (Get-PSDrive -Name master -ErrorAction SilentlyContinue)) {
        New-PSDrive -Name master -PSProvider Sitecore -Root "/" -Database "master" -ErrorAction Stop | Out-Null
    }

    # 2. get item
    $db = [Sitecore.Configuration.Factory]::GetDatabase("master")
    $item = $db.GetItem($Using:itemPath)
    if (-not $item) { return }

    # 3. device
    $device = $db.Resources.Devices.GetAll() `
        | Where-Object Name -EQ "Default"
    if (-not $device) {
        $device = $db.Resources.Devices.GetAll()[0]
    }

    # 4. get renderings
    $refs = $item.Visualization.GetRenderings($device, $true)
    if (-not $refs) {
        $empty = [PSCustomObject]@{
            uid          = $item.ID.ToGuid().ToString("D")
            placeholders = @()
        }
        ($empty | ConvertTo-Json -Depth 5) -replace "\s+", ""
        return
    }

    # 5. all placeholder paths
    $allPaths = $refs `
        | Where-Object Placeholder `
        | ForEach-Object { $_.Placeholder.TrimStart("/") } `
        | Sort-Object -Unique

    # 6. build functions
    function Build-PlaceholderObject {
        param(
            [string]    $placeholderPath,
            [array]     $allRefs
        )
        $refsHere = $allRefs `
            | Where-Object { $_.Placeholder.TrimStart("/") -ieq $placeholderPath }

        $renderings = foreach ($r in $refsHere) {
            Build-RenderingObject -ref $r -allPaths $allPaths -allRefs $allRefs
        }

        [PSCustomObject]@{
            placeholder = $placeholderPath
            renderings  = $renderings
        }
    }

    function Build-RenderingObject {
        param(
            [Sitecore.Layouts.RenderingReference] $ref,
            [string[]]                            $allPaths,
            [array]                               $allRefs
        )
        $ph = $ref.Placeholder.TrimStart("/")
        $childKeys = @()
        foreach ($candidate in $allPaths) {
            if ($candidate -like "$ph/*") {
                $rel      = $candidate.Substring($ph.Length + 1)
                $segment  = $rel.Split("/")[0]
                $childKey = "$ph/$segment"
                if ($childKeys -notcontains $childKey) {
                    $childKeys += $childKey
                }
            }
        }

        if ($childKeys.Count -gt 0) {
            $phObjs = foreach ($c in $childKeys) {
                Build-PlaceholderObject -placeholderPath $c -allRefs $allRefs
            }
        }
        else {
            $phObjs = @()
        }

        [PSCustomObject]@{
            uid          = $ref.UniqueId.ToString()
            placeholders = $phObjs
        }
    }

    # 7. top-level
    $topKeys = $allPaths | Where-Object { $_ -notlike "*/?*" }

    $placeholders = foreach ($t in $topKeys) {
        Build-PlaceholderObject -placeholderPath $t -allRefs $refs
    }

    # 8. wrap root
    $result = [PSCustomObject]@{
        uid          = $item.ID.ToGuid().ToString("D")
        placeholders = $placeholders
    }

    # 9. output
    ($result | ConvertTo-Json -Depth 10) -replace "\s+", ""
}

Stop-ScriptSession -Session $session

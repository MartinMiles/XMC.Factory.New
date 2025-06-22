# param(
#     [string]$itemPath = "/sitecore/content/Home"
# )

Set-Location -Path $PSScriptRoot

$config = Get-Content -Raw -Path ../remoting/config.LOCAL.json | ConvertFrom-Json
Write-Output "ConnectionUri: $($config.connectionUri)"
Write-Output "Username     : $($config.username)"
Write-Output "SPE Remoting Secret : $($config.SPE_REMOTING_SECRET)"

Write-Output "Get item fields of '$itemPath'..."
Import-Module -Name SPE
$session = New-ScriptSession -ConnectionUri $config.connectionUri -Username $config.username -SharedSecret $config.SPE_REMOTING_SECRET
Invoke-RemoteScript -Session $session -ScriptBlock {


    [string]$SourceDb = 'old'
    [string]$TargetDb = 'master'

# 1) Ensure SPE’s Copy-Item is loaded (must have -TransferOptions)
$copyCmd = Get-Command Copy-Item
if (-not $copyCmd.Parameters.ContainsKey('TransferOptions')) {
    throw "SPE Copy-Item isn't available - run this inside Sitecore PowerShell ISE or via SPE Remoting."
}

# 2) The two branches to clone
$pathsToCopy = @(
    '/sitecore/templates/Feature/Accounts',
    '/sitecore/templates/Feature/Demo'
)

# 3) Recursive parent-bootstrap function
function Ensure-ItemExists {
    param([string]$ItemPath)

    $targetPath = "${TargetDb}:$ItemPath"
    if (-not (Test-Path $targetPath)) {
        # First ensure the parent exists
        $parent = Split-Path $ItemPath -Parent
        if ($parent) { Ensure-ItemExists -ItemPath $parent }

        Write-Host "Creating missing item: $targetPath"
        Copy-Item `
            -Path        "${SourceDb}:$ItemPath" `
            -Destination "${TargetDb}:$parent" `
            -Recurse:$false `
            -Force `
            -TransferOptions 0
    }
}

# 4) Bootstrap all parent chains
$parentChains = $pathsToCopy |
    ForEach-Object { Split-Path $_ -Parent } |
    Sort-Object -Unique

foreach ($chain in $parentChains) {
    Write-Host "Ensuring parent chain: $chain"
    Ensure-ItemExists -ItemPath $chain
}

# 5) Full recursive copy of each branch
foreach ($path in $pathsToCopy) {
    Write-Host "Copying full tree: $path"
    Copy-Item `
        -Path        "${SourceDb}:$path" `
        -Destination "${TargetDb}:$path" `
        -Recurse `
        -Force `
        -TransferOptions 0

    Write-Host "✔ Completed: $path"
}

Write-Host "All specified branches cloned from '$SourceDb' to '$TargetDb'." -ForegroundColor Green


}
Stop-ScriptSession -Session $session
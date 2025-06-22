
# !!! THIS SCRIPT DOES NOT PRESERVE THE IDs !!!
#
# Beware !!!

param(
    [Parameter(Mandatory = $false)]
    [string]$SourceDatabase = "old",

    [Parameter(Mandatory = $false)]
    [string]$SourcePath = "/sitecore/media library/Habitat",

    [Parameter(Mandatory = $false)]
    [string]$DestinationDatabase = "master",

    [Parameter(Mandatory = $false)]
    [string]$DestinationPath     = "/sitecore/media library/Habitat"
)

# 1. Ensure both Sitecore PSDrives exist
if (-not (Get-PSDrive -Name $SourceDatabase -ErrorAction SilentlyContinue)) {
    New-PSDrive -Name $SourceDatabase `
                -PSProvider Sitecore `
                -Root "\" `
                -Database $SourceDatabase | Out-Null
}
if (-not (Get-PSDrive -Name $DestinationDatabase -ErrorAction SilentlyContinue)) {
    New-PSDrive -Name $DestinationDatabase `
                -PSProvider Sitecore `
                -Root "\" `
                -Database $DestinationDatabase | Out-Null
}

# 2. Build drive-qualified paths
$sourceRoot = "$SourceDatabase`:\" + $SourcePath
$destRoot   = "$DestinationDatabase`:\" + $DestinationPath

# 3. Create destination folder if it doesn’t already exist
if (-not (Test-Path $destRoot)) {
    # Use the Sitecore “Media folder” template for media‐library folders
    New-Item -Path $destRoot `
             -ItemType '/sitecore/templates/System/Media/Media folder' `
             -Force | Out-Null

    Write-Host "Created destination: $destRoot"
}

# 4. Copy each child item under source into the destination
Get-ChildItem -Path $sourceRoot | ForEach-Object {
    $child      = $_
    $targetPath = Join-Path -Path $destRoot -ChildPath $child.Name

    if (-not (Test-Path $targetPath)) {
        Copy-Item -Path $child.PSPath `
                  -Destination $destRoot `
                  -Recurse `
                  -Force
        Write-Host "Copied:" $child.PSPath "→" $destRoot
    }
    else {
        Write-Host "Skipped (already exists):" $targetPath
    }
}
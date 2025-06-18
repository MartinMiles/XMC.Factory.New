param(
    [Parameter(Mandatory = $false)]
    [string]$ConfigFile = ".\SqlServer.json"
)

try {
    #— Load JSON config
    if (-not (Test-Path $ConfigFile)) {
        Throw "Config file '$ConfigFile' not found."
    }
    $cfg = Get-Content -Path $ConfigFile -Raw | ConvertFrom-Json
    $ServerInstance = $cfg.ServerInstance
    $Username       = $cfg.Username
    $Password       = $cfg.Password

    #— Resolve script base name & paths
    $baseName  = [IO.Path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Name)
    $sqlPath   = Join-Path $PSScriptRoot ("$baseName.sql")

    if (-not (Test-Path $sqlPath)) {
        Throw "SQL file '$sqlPath' not found."
    }

    #— Ensure SqlServer module
    if (-not (Get-Module -ListAvailable -Name SqlServer)) {
        Throw "Install the SqlServer module: Install-Module SqlServer"
    }
    Import-Module SqlServer -ErrorAction Stop

    #— Read & validate SQL
    Write-Verbose "Loading SQL from '$sqlPath'..."
    $sqlQuery = Get-Content -Path $sqlPath -Raw
    if ([string]::IsNullOrWhiteSpace($sqlQuery)) {
        Throw "SQL file '$sqlPath' is empty."
    }

    #— Build connection string
    $connStr = @"
Server=$ServerInstance;
User Id=$Username;
Password=$Password;
Encrypt=True;
TrustServerCertificate=True;
"@

    #— Execute
    $rows = Invoke-Sqlcmd `
        -ConnectionString $connStr `
        -Query $sqlQuery `
        -ErrorAction Stop
}
catch {
    Write-Error "Failed: $($_.Exception.Message)"
    exit 1
}

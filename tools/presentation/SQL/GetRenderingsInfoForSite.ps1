<#
.SYNOPSIS
    Execute a SQL file over SQL Auth, trust the certificate, and export to CSV.

.DESCRIPTION
    Reads your .sql file, connects with SQL authentication (username/password),
    forces TrustServerCertificate to bypass untrusted‐CA errors, and writes a UTF-8 CSV.

.EXAMPLE
    .\Export-Renderings.ps1 `
      -Username svc_account `
      -Password 'P@ssw0rd!'
#>

[CmdletBinding()]
param(
    [Parameter()]
    [string]$ServerInstance = "localhost,14330",

    [Parameter()]
    [string]$Database = "Sitecore.Old",

    [Parameter()]
    [string]$Username = "sa",

    [Parameter()]
    [string]$Password = "LwU8Vt7WwFP7SW26rit",

    [Parameter()]
    [string]$QueryFile      = ".\GetRenderingsInfoForSite.sql",

    [Parameter()]
    [string]$OutputFile     = ".\GetRenderingsInfoForSite.csv"
)

try {
    # Module check
    if (-not (Get-Module -ListAvailable -Name SqlServer)) {
        Throw "Install the SqlServer module: Install-Module SqlServer"
    }

    # Read SQL
    Write-Verbose "Loading SQL from '$QueryFile'..."
    $sqlQuery = Get-Content -Path $QueryFile -Raw
    if ([string]::IsNullOrWhiteSpace($sqlQuery)) {
        Throw "Query file '$QueryFile' is empty or missing."
    }

    # Build connection string with TrustServerCertificate
    $connStr = @"
Server=$ServerInstance;
Database=$Database;
User Id=$Username;
Password=$Password;
Encrypt=True;
TrustServerCertificate=True;
"@

    # Run query
    Write-Verbose "Connecting to [$ServerInstance] DB=[$Database] as $Username..."
    $results = Invoke-Sqlcmd `
        -ConnectionString $connStr `
        -Query $sqlQuery `
        -ErrorAction Stop

    # Export CSV
    Write-Verbose "Exporting $($results.Count) rows to '$OutputFile'..."
    $results | Export-Csv -Path $OutputFile -NoTypeInformation -Encoding UTF8

    Write-Host "Export complete: $OutputFile (`$rows = $($results.Count)`)"

} catch {
    Write-Error "Failed: $($_.Exception.Message)"
    exit 1
}

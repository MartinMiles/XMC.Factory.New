param(
    [Parameter(Mandatory=$false)]
    [string]$ServiceName = 'cm'
)

Write-Host "Restarting Docker Compose service: $ServiceName"
docker-compose kill $ServiceName
docker-compose rm $ServiceName -f
docker-compose up $ServiceName -d
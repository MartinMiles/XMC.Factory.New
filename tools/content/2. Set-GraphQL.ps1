# Array of parameter sets
$jobs = @(
    @{
        ItemPath = "/sitecore/layout/Renderings/Feature/Zont/News/Latest News"
        FieldName = "ComponentQuery"
        FilePath = ".\GraphQL\LatestNews.gql"
    },
    @{
        ItemPath = "/sitecore/layout/Renderings/Feature/Zont/Navigation/Breadcrumb"
        FieldName = "ComponentQuery"
        FilePath = ".\GraphQL\Breadcrumb.gql"
    },
    @{
        ItemPath = "/sitecore/layout/Renderings/Feature/Zont/Media/Page Header Media Carousel"
        FieldName = "ComponentQuery"
        FilePath = ".\GraphQL\PageHeaderMediaCarousel.gql"
    },
    @{
        ItemPath = "/sitecore/layout/Renderings/Feature/Zont/PageContent/Page Teaser"
        FieldName = "ComponentQuery"
        FilePath = ".\GraphQL\PageTeaser.gql"
    }
)

# Loop through each job and call the child script
foreach ($job in $jobs) {
    Write-Host ""
    # Write-Host "Running Set-FieldValue-FromFile.ps1 for Template: $($job.PageTemplate), Rendering: $($job.RenderingDefinition)" -ForegroundColor Green

    try {
        & "$PSScriptRoot\Set-FieldValue-FromFile.ps1" `
            -ItemPath $job.ItemPath `
            -FieldName $job.FieldName `
            -FilePath $job.FilePath
    }
    catch {
        Write-Host "Error running Set-DatasourceField.ps1 for item Template: $($job.ItemPath), FieldName: $($job.FieldName)" -ForegroundColor Red
        Write-Host $_.Exception.Message -ForegroundColor Red
        continue
    }
}

Write-Host ""
Write-Host "All jobs completed." -ForegroundColor Cyan

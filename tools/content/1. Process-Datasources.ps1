# Set-ExecuteDatasourceField.ps1

# This script will call Set-DatasourceField.ps1 multiple times with different parameter sets.
# All output and errors are shown on the console.

# Array of parameter sets
$jobs = @(
    @{
        PageTemplate = "/sitecore/templates/Project/Zont/Habitat/Page Types/Home"
        RenderingDefinition = "/sitecore/layout/Renderings/Feature/Zont/Identity/Logo"
        Datasource = "{725A45E3-E307-4B95-B363-2782B059DF06}"
    },
    @{
        PageTemplate = "/sitecore/templates/Project/Zont/Habitat/Page Types/Home"
        RenderingDefinition = "/sitecore/layout/Renderings/Feature/Zont/Identity/Contact Information"
        Datasource = "{725A45E3-E307-4B95-B363-2782B059DF06}"
    },
    @{
        PageTemplate = "/sitecore/templates/Project/Zont/Habitat/Page Types/Home"
        RenderingDefinition = "/sitecore/layout/Renderings/Feature/Zont/Identity/Copyright"
        Datasource = "{725A45E3-E307-4B95-B363-2782B059DF06}"
    },
    @{
        PageTemplate = "/sitecore/templates/Project/Zont/Habitat/Page Types/Section"
        RenderingDefinition = "/sitecore/layout/Renderings/Feature/Zont/Identity/Logo"
        Datasource = "{725A45E3-E307-4B95-B363-2782B059DF06}"
    },
    @{
        PageTemplate = "/sitecore/templates/Project/Zont/Habitat/Page Types/Section"
        RenderingDefinition = "/sitecore/layout/Renderings/Feature/Zont/Identity/Contact Information"
        Datasource = "{725A45E3-E307-4B95-B363-2782B059DF06}"
    },
    @{
        PageTemplate = "/sitecore/templates/Project/Zont/Habitat/Page Types/Section"
        RenderingDefinition = "/sitecore/layout/Renderings/Feature/Zont/Identity/Copyright"
        Datasource = "{725A45E3-E307-4B95-B363-2782B059DF06}"
    },
    @{
        PageTemplate = "/sitecore/templates/Project/Zont/Habitat/Page Types/Article"
        RenderingDefinition = "/sitecore/layout/Renderings/Feature/Zont/Identity/Logo"
        Datasource = "{725A45E3-E307-4B95-B363-2782B059DF06}"
    },
    @{
        PageTemplate = "/sitecore/templates/Project/Zont/Habitat/Page Types/Article"
        RenderingDefinition = "/sitecore/layout/Renderings/Feature/Zont/Identity/Contact Information"
        Datasource = "{725A45E3-E307-4B95-B363-2782B059DF06}"
    },
    @{
        PageTemplate = "/sitecore/templates/Project/Zont/Habitat/Page Types/Article"
        RenderingDefinition = "/sitecore/layout/Renderings/Feature/Zont/Identity/Copyright"
        Datasource = "{725A45E3-E307-4B95-B363-2782B059DF06}"
    }
)

# Loop through each job and call the child script
foreach ($job in $jobs) {
    Write-Host ""
    Write-Host "Running Set-DatasourceField.ps1 for Template: $($job.PageTemplate), Rendering: $($job.RenderingDefinition)" -ForegroundColor Green

    try {
        & "$PSScriptRoot\Set-DatasourceField.ps1" `
            -PageTemplate $job.PageTemplate `
            -RenderingDefinition $job.RenderingDefinition `
            -Datasource $job.Datasource
    }
    catch {
        Write-Host "Error running Set-DatasourceField.ps1 with Template: $($job.PageTemplate), Rendering: $($job.RenderingDefinition)" -ForegroundColor Red
        Write-Host $_.Exception.Message -ForegroundColor Red
        continue
    }
}

Write-Host ""
Write-Host "All jobs completed." -ForegroundColor Cyan

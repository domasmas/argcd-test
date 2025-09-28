# Build and Push All Color Apps to Docker Hub

param(
    [string]$Tag = "latest"
)

Write-Host "Building and pushing all color apps to Docker Hub" -ForegroundColor Green
Write-Host "=================================================="

$colorApps = @("blue-app", "green-app", "purple-app", "red-app", "yellow-app")
$successful = @()
$failed = @()

foreach ($app in $colorApps) {
    Write-Host "Building $app..." -ForegroundColor Cyan
    
    if (Test-Path $app) {
        Push-Location $app
        try {
            if (Test-Path "build-and-push.ps1") {
                .\build-and-push.ps1 -Tag $Tag
                if ($LASTEXITCODE -eq 0) {
                    $successful += $app
                    Write-Host "✓ $app completed successfully" -ForegroundColor Green
                } else {
                    $failed += $app
                    Write-Host "✗ $app failed" -ForegroundColor Red
                }
            } else {
                Write-Host "✗ build-and-push.ps1 not found in $app" -ForegroundColor Red
                $failed += $app
            }
        } catch {
            Write-Host "✗ Error building $app : $_" -ForegroundColor Red
            $failed += $app
        }
        Pop-Location
    } else {
        Write-Host "✗ Directory $app not found" -ForegroundColor Red
        $failed += $app
    }
    Write-Host ""
}

# Summary
Write-Host "=================================================="
Write-Host "BUILD SUMMARY"
Write-Host "=================================================="

Write-Host "✓ Successfully built: $($successful.Count) apps" -ForegroundColor Green
foreach ($app in $successful) {
    Write-Host "  - $app" -ForegroundColor Green
}

if ($failed.Count -gt 0) {
    Write-Host "✗ Failed to build: $($failed.Count) apps" -ForegroundColor Red
    foreach ($app in $failed) {
        Write-Host "  - $app" -ForegroundColor Red
    }
} else {
    Write-Host "🚀 All color apps built and pushed successfully!" -ForegroundColor Green
}
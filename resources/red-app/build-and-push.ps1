param(
    [string]$Tag = "latest"
)

$ErrorActionPreference = "Stop"

if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
    throw "Docker CLI is required but was not found in PATH."
}

if (-not (Get-Command dotnet -ErrorAction SilentlyContinue)) {
    throw ".NET SDK is required but was not found in PATH."
}

$projectDirectory = Split-Path -Leaf (Get-Location)
$repository = "domasmasiulis/$projectDirectory"
$imageName = "$repository`:$Tag"

Write-Host "Building Docker image $imageName from $projectDirectory" -ForegroundColor Cyan

docker build --pull -t $imageName .

Write-Host "Pushing $imageName to Docker Hub (make sure you ran 'docker login' first)" -ForegroundColor Yellow

docker push $imageName

Write-Host "Done." -ForegroundColor Green

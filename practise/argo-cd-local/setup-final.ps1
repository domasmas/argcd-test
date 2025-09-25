# Argo CD Local Setup - Complete Automated Script

Write-Host "Starting Argo CD Local Setup..." -ForegroundColor Green
Write-Host "======================================"

# Check if Docker is running
try {
    docker info | Out-Null
    Write-Host "Docker is running" -ForegroundColor Green
} catch {
    Write-Host "Docker is not running. Please start Docker Desktop and try again." -ForegroundColor Red
    exit 1
}

# Check if kubectl is available
try {
    kubectl version --client | Out-Null
    Write-Host "kubectl is available" -ForegroundColor Green
} catch {
    Write-Host "kubectl is not available. Please install kubectl." -ForegroundColor Red
    exit 1
}

# Check if Kubernetes cluster is accessible
try {
    kubectl cluster-info | Out-Null
    Write-Host "Kubernetes cluster is accessible" -ForegroundColor Green
} catch {
    Write-Host "Kubernetes cluster is not accessible. Please enable Kubernetes in Docker Desktop." -ForegroundColor Red
    exit 1
}

# Stop any existing Argo CD setup
Write-Host "Cleaning up any existing setup..." -ForegroundColor Yellow
docker-compose down -v 2>$null
kubectl delete namespace argocd --ignore-not-found=true 2>$null

# Create argocd namespace
Write-Host "Creating argocd namespace..." -ForegroundColor Yellow
kubectl create namespace argocd
if ($LASTEXITCODE -ne 0) {
    Write-Host "Failed to create argocd namespace" -ForegroundColor Red
    exit 1
}

# Install Argo CD CRDs first
Write-Host "Installing Argo CD CRDs..." -ForegroundColor Yellow
kubectl apply -f crds.yaml
if ($LASTEXITCODE -ne 0) {
    Write-Host "Failed to create Argo CD CRDs" -ForegroundColor Red
    exit 1
}

# Install Argo CD resources (ConfigMaps, Secrets, RBAC)
Write-Host "Installing Argo CD resources..." -ForegroundColor Yellow
kubectl apply -f resources.yaml
if ($LASTEXITCODE -ne 0) {
    Write-Host "Failed to create Argo CD resources" -ForegroundColor Red
    exit 1
}

# Install default AppProject
Write-Host "Installing default AppProject..." -ForegroundColor Yellow
kubectl apply -f default-project.yaml
if ($LASTEXITCODE -ne 0) {
    Write-Host "Failed to create default AppProject" -ForegroundColor Red
    exit 1
}

Write-Host "Kubernetes resources created successfully" -ForegroundColor Green

# Start Argo CD services with Docker Compose
Write-Host "Starting Argo CD services..." -ForegroundColor Yellow
docker-compose up -d
if ($LASTEXITCODE -ne 0) {
    Write-Host "Failed to start Docker Compose services" -ForegroundColor Red
    exit 1
}

# Wait for services to be ready
Write-Host "Waiting for Argo CD to be ready..." -ForegroundColor Yellow
Start-Sleep 15

# Check if Argo CD server is responding
$ready = $false
for ($i = 1; $i -le 20; $i++) {
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:8088/healthz" -Method Get -TimeoutSec 5 -ErrorAction SilentlyContinue
        if ($response.StatusCode -eq 200) {
            Write-Host "Argo CD is ready!" -ForegroundColor Green
            $ready = $true
            break
        }
    } catch {
        # Service not ready yet
    }
    Write-Host "Still waiting... ($i/20)" -ForegroundColor Yellow
    Start-Sleep 3
}

if (-not $ready) {
    Write-Host "Argo CD might still be starting up. Check manually with 'docker-compose logs'" -ForegroundColor Yellow
    Write-Host "To troubleshoot: docker-compose logs -f" -ForegroundColor Gray
} else {
    Write-Host ""
    Write-Host "SUCCESS! Argo CD is running and accessible!" -ForegroundColor Green
}

Write-Host ""
Write-Host "Argo CD Setup Complete!" -ForegroundColor Green
Write-Host "=========================="
Write-Host "Web UI URL: http://localhost:8088" -ForegroundColor Cyan
Write-Host "Username: admin" -ForegroundColor Cyan
Write-Host "Password: admin" -ForegroundColor Cyan
Write-Host ""
Write-Host "Useful Commands:" -ForegroundColor White
Write-Host "  - Stop Argo CD: docker-compose down" -ForegroundColor Gray
Write-Host "  - View logs: docker-compose logs -f" -ForegroundColor Gray
Write-Host "  - Restart: docker-compose restart" -ForegroundColor Gray
Write-Host "  - Clean everything: docker-compose down -v && kubectl delete namespace argocd" -ForegroundColor Gray
Write-Host ""
Write-Host "Open your browser and navigate to: http://localhost:8088" -ForegroundColor Green
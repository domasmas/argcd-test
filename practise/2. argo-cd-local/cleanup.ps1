# Complete ArgoCD Cleanup Script

Write-Host "Starting complete ArgoCD cleanup..." -ForegroundColor Red
Write-Host "===================================="

# Delete all ArgoCD applications first
Write-Host "Deleting ArgoCD applications..." -ForegroundColor Yellow
kubectl delete applications --all -n argocd --ignore-not-found=true --force --grace-period=0 2>$null

# Delete all ArgoCD app projects
Write-Host "Deleting ArgoCD projects..." -ForegroundColor Yellow
kubectl delete appprojects --all -n argocd --ignore-not-found=true --force --grace-period=0 2>$null

# Delete cluster role bindings
Write-Host "Deleting cluster role bindings..." -ForegroundColor Yellow
kubectl delete clusterrolebinding argocd-server-cluster-admin --ignore-not-found=true 2>$null
kubectl delete clusterrolebinding argocd-application-controller-cluster-admin --ignore-not-found=true 2>$null

# Delete any ArgoCD cluster roles
Write-Host "Deleting cluster roles..." -ForegroundColor Yellow
kubectl delete clusterrole argocd-server --ignore-not-found=true 2>$null
kubectl delete clusterrole argocd-application-controller --ignore-not-found=true 2>$null

# Force delete the ArgoCD namespace
Write-Host "Deleting ArgoCD namespace..." -ForegroundColor Yellow
kubectl delete namespace argocd --ignore-not-found=true --force --grace-period=0 2>$null

# Wait for namespace deletion with active polling (max 30 seconds)
Write-Host "Waiting for complete cleanup..." -ForegroundColor Yellow
$cleanupWait = 0
$cleaned = $false

while ($cleanupWait -lt 30 -and -not $cleaned) {
    $nsExists = kubectl get namespace argocd 2>$null
    if ($LASTEXITCODE -ne 0) {
        $cleaned = $true
        break
    }
    Write-Host "." -NoNewline -ForegroundColor Yellow
    Start-Sleep 2
    $cleanupWait += 2
}
Write-Host ""

if ($cleaned) {
    Write-Host "✓ ArgoCD completely removed" -ForegroundColor Green
} else {
    Write-Host "⚠ Some resources may still be terminating" -ForegroundColor Yellow
    kubectl get all -n argocd 2>$null
}

# Check for any remaining ArgoCD resources
$remainingResources = kubectl get all -A | Select-String "argocd" 2>$null
if ($remainingResources) {
    Write-Host "⚠ Found remaining ArgoCD resources:" -ForegroundColor Yellow
    $remainingResources | ForEach-Object { Write-Host "  $_" -ForegroundColor Gray }
} else {
    Write-Host "✓ No remaining ArgoCD resources found" -ForegroundColor Green
}

Write-Host ""
Write-Host "🧹 ArgoCD Cleanup Complete!" -ForegroundColor Green
Write-Host ""
Write-Host "You can now run setup.ps1 for a fresh installation." -ForegroundColor Gray
# Cleanup Script for ArgoCD Exercises 4, 5, and 6

Write-Host "Cleaning up ArgoCD Exercises..." -ForegroundColor Yellow
Write-Host "==============================="

# Delete all ArgoCD applications
Write-Host "Deleting ArgoCD applications..." -ForegroundColor Cyan
kubectl delete applications --all -n argocd --ignore-not-found=true

# Delete exercise namespaces with force
$namespaces = @("sync-form", "blue-app-domas", "blue-app-david", "blue-app-jason", "blue-app-martyn", "blue-app-max", "demo", "test", "example", "workshop")

Write-Host "Force deleting exercise namespaces..." -ForegroundColor Cyan
foreach ($ns in $namespaces) {
    Write-Host "Deleting namespace: $ns" -ForegroundColor Yellow
    kubectl delete namespace $ns --ignore-not-found=true --force --grace-period=0
}

Write-Host ""
Write-Host "Cleanup completed!" -ForegroundColor Green
Write-Host "Current state:" -ForegroundColor Yellow
kubectl get applications -n argocd
kubectl get namespaces
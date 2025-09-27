param(
    [Parameter(Mandatory = $true)]
    [string]$RepositoryUrl,

    [string]$Revision = "main",
    [string]$AppName = "rollback-blue-to-purple-martyn",
    [string]$Namespace = "blue-app-martyn"
)

$ErrorActionPreference = "Stop"

if (-not (Get-Command kubectl -ErrorAction SilentlyContinue)) {
    throw "kubectl is required but was not found in PATH."
}

$applicationDefinition = @"
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: $AppName
  namespace: argocd
spec:
  project: default
  source:
    repoURL: $RepositoryUrl
    targetRevision: $Revision
    path: practise/5. argo-rollback/martyn/k8s
  destination:
    server: https://kubernetes.default.svc
    namespace: $Namespace
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
      - CreateNamespace=true
"@

Write-Host "Applying Argo CD Application '$AppName'" -ForegroundColor Cyan
$applicationDefinition | kubectl apply -f - | Out-Host

Write-Host "Application registered. Argo CD will sync to the blue app image by default." -ForegroundColor Green
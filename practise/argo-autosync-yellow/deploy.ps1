param(
    [Parameter(Mandatory = $true)]
    [string]$RepositoryUrl,

    [string]$Revision = "main",
    [string]$AppName = "yellow-app-autosync",
    [string]$Namespace = "yellow-app"
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
    path: practise/argo-autosync-yellow/k8s
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

Write-Host "Application registered. Argo CD will reconcile the manifests automatically." -ForegroundColor Green

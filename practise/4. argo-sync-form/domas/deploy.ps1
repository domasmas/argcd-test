param(
    [Parameter(Mandatory = $true)]
    [string]$RepositoryUrl,

    [string]$Revision = "main",
    [string]$AppName = "sync-form-lab",
    [string]$Namespace = "sync-form"
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
    path: practise/4. argo-sync-form/domas/k8s
  destination:
    server: https://kubernetes.default.svc
    namespace: $Namespace
"@

Write-Host "Applying Argo CD Application '$AppName'" -ForegroundColor Cyan
$applicationDefinition | kubectl apply -f - | Out-Host

Write-Host "Application registered with manual sync. Open the Argo CD UI to experiment with the Sync form." -ForegroundColor Green

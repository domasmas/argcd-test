# Argo CD Auto-Healing Exercise (Yellow App)

This practice lab shows how Argo CD's automated sync and self-healing features keep your application in the desired state. You'll deploy the color-themed **Yellow App** (with built-in pod identity) and watch Argo CD fix drift automatically.

## What You'll Do

1. Deploy an Argo CD `Application` that points to the manifests in this folder.
2. Let Argo CD create two replicas of the Yellow App.
3. Break the live state (delete pods, scale the deployment) and watch Argo CD correct it.

## Prerequisites

- Local Argo CD instance running (see `practise/argo-cd-local/setup.ps1`).
- This repository pushed to a Git host Argo CD can reach (GitHub, GitLab, etc.).
- `kubectl` configured for the same Kubernetes cluster as Argo CD.
- Yellow App container image available at `domasmasiulis/yellow-app:latest` (run the build script if you need a fresh image).

## Deploy with One Command

Run the provided script from this folder, passing the Git repository URL that Argo CD should watch:

```powershell
# From repo root
cd practise/argo-autosync-yellow
./deploy.ps1 -RepositoryUrl "https://github.com/<your-username>/argcd-test" -Revision main
```

The script will:

- Ensure `kubectl` is available.
- Create (or update) an Argo CD `Application` named `yellow-app-autosync` in the `argocd` namespace.
- Enable automated sync, pruning, and self-healing so Argo CD continuously reconciles the manifests under `practise/argo-autosync-yellow/k8s`.

After a few moments, you should see:

```powershell
kubectl get pods -n yellow-app
```

Two pods should be running, each showing a different random human name in the UI (refresh your browser to hit each pod via the service: `http://localhost:30085`).

## Auto-Healing Experiments

Try each scenario below and observe how Argo CD responds:

1. **Delete a pod**

   ```powershell
   kubectl delete pod -n yellow-app -l app=yellow-app
   ```

   The Deployment immediately recreates it, and Argo CD confirms health stays green.

2. **Introduce drift by scaling manually**

   ```powershell
   kubectl scale deployment yellow-app -n yellow-app --replicas=1
   ```

   Within a few moments, Argo CD detects the drift and scales the Deployment back to 2 replicas (thanks to `selfHeal: true`).

3. **Change container image live**
   ```powershell
   kubectl set image deployment/yellow-app yellow-app=nginx:alpine -n yellow-app
   ```
   Argo CD notices the image mismatch and reverts it to `domasmasiulis/yellow-app:latest`.

Use the Argo CD UI to watch events and diffs in real time. Every change you make directly in the cluster is overwritten by Argo CD so that the live state matches Git.

## Clean Up

When you're finished:

```powershell
kubectl delete application yellow-app-autosync -n argocd
kubectl delete namespace yellow-app
```

Alternatively, simply remove the `Application` from the Argo CD UI; the namespace will be pruned automatically because pruning is enabled.

## Next Steps

- Try changing the manifests here (e.g., update the Service node port) and push to Git—Argo CD will roll out the new desired state.
- Enable `retry` options in the `syncPolicy` to see how Argo CD handles transient errors.
- Explore Argo CD notifications to alert when drift or sync failures occur.

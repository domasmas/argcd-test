# Argo CD Sync Form Deep-Dive

This exercise demonstrates how every toggle in Argo CD’s **Sync** drawer affects the reconciliation of the colour apps (green, blue, yellow, purple, red). Each scenario tweaks the behaviour of the `sync-form-lab` application so you can observe GitOps principles in action.

> **Heads-up:** The **Red App** intentionally crashes a few seconds after start-up. You will use it later to explore retries and replacements.

## 1. Prerequisites

- Argo CD installed locally (run `practise/2. argo-cd-local/setup.ps1` if you need a local instance).
- This repository pushed to a Git host reachable by Argo CD.
- `kubectl` pointing at the same Kubernetes cluster Argo CD manages.
- All colour app images pushed (use the scripts under `resources/<colour>-app/` if required).

## 2. Register the lab application

From the repo root:

```powershell
cd practise/4. argo-sync-form/domas
./deploy.ps1 -RepositoryUrl "https://github.com/<your-username>/argcd-test" -Revision main
```

This creates an Argo CD application called `sync-form-lab` that targets the manifests in this folder and deploys into the `sync-form` namespace. When you open the Argo CD UI (http://localhost:30088 by default) the app will show **OutOfSync** until the first sync completes.

## 3. Sync form cheat sheet

![Sync form reference](../.images/sync-form.png)

| Control                                                                | What it does                                                        | Suggested scenario                                                   |
| ---------------------------------------------------------------------- | ------------------------------------------------------------------- | -------------------------------------------------------------------- |
| **Prune**                                                              | Deletes cluster resources that exist live but not in Git            | Remove a resource from Git and watch it vanish when Prune is checked |
| **Dry Run**                                                            | Renders manifests and diffs without applying changes                | Preview a switch from Green → Blue                                   |
| **Apply Only**                                                         | Skips deletions even when Prune is selected                         | Compare with previous step to see resources linger                   |
| **Force**                                                              | Replaces immutable fields using `kubectl replace --force` semantics | Swap between Blue ↔ Yellow rapidly to observe rollout                |
| **Sync Options** (Skip Schema Validation, Auto-Create Namespace, etc.) | Adjusts how Argo CD performs its `kubectl apply` calls              | Each scenario below highlights a different toggle                    |
| **Prune Propagation Policy / Prune Last**                              | Controls ordering and cascading of deletions                        | Remove extra resources and watch foreground/background behaviour     |
| **Replace**                                                            | Uses `kubectl replace` instead of apply                             | Reset a deployment stuck with immutable field changes                |
| **Retry**                                                              | Configures automatic retry when sync fails                          | Pair with the crashing Red App                                       |
| **Synchronize resources** filters                                      | Limits sync to selected resources                                   | Update only the Deployment or only the Service                       |

Keep this table handy while you work through the scenarios.

## 4. Scenario walkthroughs (with tips)

Assume the repo matches `main` and the Argo CD application is named `sync-form-lab` unless stated otherwise.

### UI landmarks worth watching

After clicking the application tile you will see the horizontal action bar: **DETAILS**, **DIFF**, **SYNC**, **SYNC STATUS**, **HISTORY AND ROLLBACK**, etc.

- **DETAILS → Events** shows the Kubernetes API calls Argo CD is issuing.
- **DIFF** lets you compare Git vs live state before committing to a sync.
- **SYNC** opens the drawer where you toggle the options discussed here.
- **SYNC STATUS** summarises what the last operation changed.
- **HISTORY AND ROLLBACK** records the options used for each past sync.

Tip: run `kubectl get pods -n sync-form --watch` and `kubectl get events -n sync-form --watch` in separate terminals if you prefer a CLI view of the action.

### 4.1 First sync – Auto-create namespace

1. Confirm the namespace doesn’t exist yet: `kubectl get ns sync-form` (should return _NotFound_).
2. In the Argo CD UI click **SYNC**.
3. Tick **Auto-Create Namespace** and leave every other option unchecked.
4. Click **SYNCHRONIZE**. If the operation stalls or errors, retry once or twice—Docker Desktop clusters sometimes need a nudge.
5. In **DETAILS → Events** note `namespace/sync-form created`, followed by the Service, ConfigMap, and Deployment creations.
6. Run `kubectl get pods -n sync-form` to confirm one pod named similar to `sync-form-app-xxxx` is running.
7. Browse to http://localhost:30087 to check the Green App is reachable.

### 4.2 Dry run vs apply – proving dry run is safe

1. Edit `k8s/deployment.yaml` and change the image to `domasmasiulis/blue-app:latest`.
2. Commit and push:
   ```powershell
   git status
   git commit -am "Switch lab deployment to blue app"
   git push
   ```
3. Back in Argo CD, click **SYNC** and tick only **Dry Run**.
4. Click **SYNCHRONIZE**; the toast should say the operation succeeded in Dry Run mode.
5. Inspect **DIFF** to see the rendered change, then open **SYNC STATUS** to confirm no resources were modified.
6. Verify the live pod is still running the old image: `kubectl get pod -n sync-form -o jsonpath='{.items[0].spec.containers[0].image}'`.
7. (Optional) Repeat with the unstable Red App image to preview a failure without impacting the cluster.
8. When ready, run a normal sync (Dry Run unchecked) to roll out the Blue App and confirm the pod image updates.

> **Reset for later:** leave the Deployment pointing at `domasmasiulis/blue-app:latest` unless a later step says otherwise.

### 4.3 Prune vs Apply Only – pruning a managed ConfigMap

1. Clean the slate and ensure Argo CD manages the baseline resources:
   ```powershell
   kubectl delete configmap stray-settings -n sync-form --ignore-not-found
   # In the Argo CD UI: click SYNC and synchronize (no special options needed)
   ```
2. Confirm the managed ConfigMap exists: `kubectl get configmap app-settings -n sync-form` (it comes from `k8s/configmap.yaml`).
3. Simulate removing it from Git:
   - Edit `k8s/kustomization.yaml` and temporarily remove the line `- configmap.yaml`.
   - Commit and push the change so Argo CD sees the new desired state.
4. The application will show **OutOfSync**. Click **SYNC**, tick **Prune**, leave other toggles off, and run the sync.
5. In **DETAILS → Events** observe `configmap/app-settings deleted`. Verify with `kubectl get configmap app-settings -n sync-form` (should return _NotFound_).
6. Restore the configmap in Git:
   - Re-add `- configmap.yaml` to `kustomization.yaml`.
   - Commit, push, and run a normal sync so the ConfigMap is recreated.
7. Remove the line again, commit, and push—this sets up a second prune scenario.
8. This time run **SYNC** with **Apply Only** checked.
9. **SYNC STATUS** should report that prune was skipped because apply-only mode is enabled. Confirm the ConfigMap still exists in the cluster.
10. Restore the final state by putting `- configmap.yaml` back, committing, pushing, and syncing once more.

### 4.4 Prune propagation policy & prune last

1. Add a temporary file `k8s/extra-service.yaml` (duplicate the Service with a new name `sync-form-app-temp`) and reference it in `kustomization.yaml`.
2. Commit, push, and sync so both services exist.
3. Remove the file and its reference, commit, and push.
4. Sync with **Prune** and set **Prune Propagation Policy** to `background`. Watch the service disappear while the sync completes immediately.
5. Repeat with `foreground` to see the sync wait for deletion confirmation.
6. Enable **Prune Last** and remove another temporary resource to observe update-before-delete ordering.
7. Clean up any temporary files in Git before proceeding.

### 4.5 Retry with the Red App – controlled failure

1. Switch the Deployment image to `domasmasiulis/red-app:latest`, commit, and push.
2. In the sync drawer expand **Retry**, set **Limit** to `3`, **Backoff** to `5s`, and sync.
3. The pod crashes repeatedly; **SYNC STATUS** increments the retry count until it gives up.
4. Restore a healthy image (e.g., Blue), commit, push, and sync to return to normal.

### 4.6 Apply out-of-sync only – drift correction

1. Without touching Git, scale the deployment: `kubectl scale deployment sync-form-app -n sync-form --replicas=3`.
2. In Argo CD the app shows OutOfSync. Run **SYNC** with **Apply Out of Sync Only** checked.
3. Only the Deployment is updated; the Service is skipped. Confirm the replica count returns to 1.

## 5. Clean up

When you are done:

```powershell
kubectl delete application sync-form-lab -n argocd
kubectl delete namespace sync-form
```

## 6. Extension ideas

- Combine this lab with the rollback exercises to see how sync options influence history reconciliation.
- Add `ignoreDifferences` rules to the Application and experiment with **Respect Ignore Differences** in the sync drawer.
- Compare the **Last Applied** view in Argo CD with `kubectl apply --server-side --dry-run=client` outputs for the same manifests.

Enjoy exploring! The colour apps give instant visual feedback while you master every checkbox in Argo CD’s sync form.

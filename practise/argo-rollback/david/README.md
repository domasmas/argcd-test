# Argo CD Rollback Drill – David

This lab walks you through an automated rollout from the **Blue App** to the **Purple App**, then a manual rollback using the Argo CD UI. Because it lives in your own folder, you can push changes without colliding with other students.

## 1. Deploy the baseline (Blue App)

```powershell
# From repo root
cd practise/argo-rollback/david
./deploy.ps1 -RepositoryUrl "https://github.com/<your-username>/argcd-test" -Revision main
```

The script registers an Argo CD application named `rollback-blue-to-purple-david` with auto-sync enabled. Within a few moments you should see one pod running the blue app in namespace `blue-app-david`.

Verify:

```powershell
kubectl get pods -n blue-app-david
kubectl get svc -n blue-app-david
```

Browse to `http://localhost:30083` to confirm the blue UI.

## 2. Trigger a rollout to the Purple App via GitOps

1. Edit `practise/argo-rollback/david/k8s/kustomization.yaml`.
2. Change the `newName` under the `images` section from `domasmasiulis/blue-app` to `domasmasiulis/purple-app`.
3. Commit and push your change.

Example diff:

```diff
-images:
-  - name: domasmasiulis/blue-app
-    newName: domasmasiulis/blue-app
-    newTag: latest
+images:
+  - name: domasmasiulis/blue-app
+    newName: domasmasiulis/purple-app
+    newTag: latest
```

Once the commit reaches the remote, Argo CD detects it and automatically syncs. Watch your app switch to the purple theme in both the UI and the service endpoint (`http://localhost:30083`).

## 3. Practice an Argo CD rollback

1. In the Argo CD UI, open the `rollback-blue-to-purple-david` application.
2. Open the **History and Rollback** menu and select the previous revision (the blue app deployment).
3. Confirm the rollback.

Argo CD immediately reapplies the earlier manifest revision, restoring the blue app pod. Refresh `http://localhost:30083` to confirm the change.

## 4. Optional clean-up

```powershell
kubectl delete application rollback-blue-to-purple-david -n argocd
kubectl delete namespace blue-app-david
```

Feel free to repeat the rollout / rollback cycle by editing `kustomization.yaml` again. Because the Argo CD app prunes and self-heals, the UI gives you a clear view of each state change.

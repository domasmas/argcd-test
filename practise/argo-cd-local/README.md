# Argo CD Local Setup Exercise

This exercise guides you through setting up a local Argo CD instance on Kubernetes using Docker Desktop. This will be the foundation for all subsequent GitOps exercises in this workshop.

## Prerequisites

Before starting this exercise, ensure you have:

- **Docker Desktop** installed and running
- **Kubernetes** enabled in Docker Desktop
- **kubectl** command-line tool installed and configured
- **PowerShell** (Windows) or compatible shell

### Verify Prerequisites

Check if your environment is ready:

```powershell
# Check if kubectl is working
kubectl version --client

# Check if Kubernetes cluster is accessible
kubectl cluster-info

# Check if Docker Desktop is running
docker version
```

## What You'll Learn

- How to install Argo CD on a local Kubernetes cluster
- How to access the Argo CD web interface
- Basic Argo CD concepts and navigation
- How to prepare for GitOps workflows

## Exercise Overview

This exercise will:

1. **Clean up** any existing Argo CD installations
2. **Install** Argo CD using official Kubernetes manifests
3. **Expose** the Argo CD server for local access
4. **Configure** initial access credentials
5. **Add** an example repository for testing

## Step-by-Step Instructions

### Step 1: Run the Setup Script

The provided `setup.ps1` script automates the entire Argo CD installation process:

```powershell
# Navigate to the exercise directory
cd practise\argo-cd-local

# Run the setup script
.\setup.ps1
```

### Step 2: What the Script Does

The setup script performs these actions automatically:

1. **Environment Checks**

   - Verifies kubectl is installed and working
   - Confirms Kubernetes cluster accessibility

2. **Clean Installation**

   - Removes any existing ArgoCD installations
   - Creates a fresh `argocd` namespace

3. **ArgoCD Installation**

   - Downloads and applies official ArgoCD manifests
   - Waits for all pods to become ready

4. **Service Exposure**

   - Configures NodePort service for easy local access
   - Exposes ArgoCD on ports 30088 (HTTP) and 30443 (HTTPS)

5. **Initial Configuration**
   - Retrieves the admin password
   - Adds an example repository for testing
   - Copies the password to clipboard

### Step 3: Access Argo CD Web Interface

After the script completes successfully:

1. **Open your browser** and navigate to: http://localhost:30088
2. **Login credentials:**
   - **Username:** `admin`
   - **Password:** (displayed by the setup script and copied to clipboard)

### Step 4: Explore the Argo CD Interface

Once logged in, familiarize yourself with:

1. **Applications Dashboard** - Overview of all managed applications
2. **Settings** - Configuration for repositories, clusters, and projects
3. **User Info** - Account settings and password management

## Understanding the Installation

### Architecture Components

The installation creates several key components:

- **argocd-server**: The API server and web UI
- **argocd-repo-server**: Repository service for Git operations
- **argocd-application-controller**: Main controller managing applications
- **argocd-dex-server**: Authentication service
- **argocd-redis**: Cache and session storage

### Network Access

The setup uses **NodePort** instead of port-forwarding for reliable access:

- **HTTP**: http://localhost:30088
- **HTTPS**: https://localhost:30443 (self-signed certificate)

This approach ensures consistent access without needing to maintain port-forward sessions.

## Common Commands

Here are useful commands for managing your Argo CD installation:

```powershell
# View all ArgoCD pods
kubectl get pods -n argocd

# Check ArgoCD server status
kubectl get svc -n argocd

# View ArgoCD server logs
kubectl logs -f deployment/argocd-server -n argocd

# Get admin password (if needed again)
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | ForEach-Object {[System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($_))}

# Check cluster connection status
kubectl get nodes

# View all namespaces
kubectl get namespaces
```

## Troubleshooting

### Common Issues and Solutions

**🚨 "kubectl is not available"**

- Install kubectl: https://kubernetes.io/docs/tasks/tools/
- Ensure it's in your PATH

**🚨 "Kubernetes cluster is not accessible"**

- Enable Kubernetes in Docker Desktop settings
- Wait for Kubernetes to fully start (green status in Docker Desktop)
- Try restarting Docker Desktop

**🚨 "Pods not ready after waiting"**

- Check if you have enough system resources
- Try: `kubectl describe pods -n argocd` to see detailed status
- Restart the setup script after ensuring resources are available

**🚨 "Cannot access web interface"**

- Verify the service is running: `kubectl get svc -n argocd`
- Check if port 30088 is available
- Try accessing via HTTPS: https://localhost:30443

**🚨 "Password not working"**

- Re-run the password command above
- Check if the argocd-initial-admin-secret exists: `kubectl get secrets -n argocd`

## Verification Steps

Confirm your installation is working correctly:

1. **Web Interface Access**

   ```
   ✓ Can access http://localhost:30088
   ✓ Can login with admin credentials
   ✓ Dashboard loads without errors
   ```

2. **Cluster Status**

   ```powershell
   kubectl get pods -n argocd
   # All pods should show "Running" status
   ```

3. **Service Connectivity**
   ```powershell
   kubectl get svc -n argocd argocd-server
   # Should show NodePort configuration
   ```

## Security Considerations

For this local development setup:

- **Default passwords** are used (change them in production)
- **Self-signed certificates** are acceptable for local use
- **NodePort exposure** is fine for local development only

## Clean Up

When you're finished with all exercises, you can remove Argo CD:

```powershell
# Complete cleanup
kubectl delete namespace argocd

# Verify removal
kubectl get namespaces
```

## Next Steps

With Argo CD running locally, you're ready for:

1. **[Deploy .NET App with GitOps](../dotnet-app-deployment/README.md)** - Create your first GitOps application
2. **[Hands-on Kustomize](../hands-on-kustomize/README.md)** - Learn configuration management with Kustomize

## Additional Resources

- **Official Argo CD Documentation**: https://argo-cd.readthedocs.io/
- **Getting Started Guide**: https://argo-cd.readthedocs.io/en/stable/getting_started/
- **Best Practices**: https://argo-cd.readthedocs.io/en/stable/user-guide/best_practices/

---

## Exercise Completion Checklist

- [ ] Prerequisites verified (kubectl, Docker Desktop, Kubernetes)
- [ ] Setup script executed successfully
- [ ] Argo CD web interface accessible at http://localhost:30088
- [ ] Successfully logged in with admin credentials
- [ ] Explored the Argo CD dashboard and navigation
- [ ] All ArgoCD pods showing "Running" status
- [ ] Ready to proceed with GitOps application deployments

**🎉 Congratulations!** You now have a fully functional local Argo CD instance ready for GitOps workflows.

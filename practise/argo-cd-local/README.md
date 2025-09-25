# 🥑 Argo CD Local Setup Exercise

This exercise sets up a complete Argo CD environment locally using Docker Compose and a local Kubernetes cluster.

## Prerequisites

1. **Docker Desktop** with Kubernetes enabled
2. **kubectl** configured to access your local cluster
3. **PowerShell** for running the setup script

## Quick Start

Simply run the setup script:

```powershell
.\setup.ps1
```

This will automatically:

- Clean up any existing setup
- Create the `argocd` namespace
- Install Argo CD Custom Resource Definitions (CRDs)
- Install all required Kubernetes resources
- Start Argo CD services with Docker Compose
- Retrieve and display the admin login credentials
- Copy the password to your clipboard for easy login

## What Gets Installed

### Kubernetes Resources

- **Namespace**: `argocd`
- **CRDs**: Application and AppProject definitions
- **ConfigMaps**: Core configuration, RBAC, and command parameters
- **Secrets**: Admin password and server secrets
- **ServiceAccounts**: For server, controller, and repo server
- **RBAC**: ClusterRoles and bindings for proper permissions
- **AppProject**: Default project for applications

### Docker Services

- **argocd-server**: Web UI and API server
- **argocd-application-controller**: Manages applications
- **argocd-repo-server**: Handles Git repositories
- **redis**: Cache for Argo CD

## Accessing Argo CD

Once the setup completes successfully:

- **Web UI**: http://localhost:8088
- **Username**: `admin`
- **Password**: (displayed by setup script and copied to clipboard)

**Tip**: The setup script automatically copies the password to your clipboard, so you can simply paste it (Ctrl+V) into the login form!

## File Structure

```
├── docker-compose.yml      # Docker services definition
├── setup.ps1              # Main setup script
├── crds.yaml              # Custom Resource Definitions
├── resources.yaml         # Core Kubernetes resources
├── default-project.yaml   # Default AppProject
└── README.md              # This file
```

## Troubleshooting

### Check Container Status

```powershell
docker-compose ps
```

### View Logs

```powershell
# All services
docker-compose logs -f

# Specific service
docker-compose logs -f argocd-server
```

### Verify Kubernetes Resources

```powershell
kubectl get all -n argocd
kubectl get configmaps -n argocd
kubectl get secrets -n argocd
```

### Common Issues

1. **Containers restarting**: Check logs for specific error messages
2. **Web UI not accessible**: Wait a bit longer, services take time to start
3. **Permission errors**: Ensure Docker Desktop has Kubernetes enabled
4. **kubectl not found**: Install kubectl and add to PATH
5. **Password not in clipboard**: If clipboard copy fails, the password is still displayed in the terminal output

### Get Password Manually

If you need to retrieve the password again later:

```powershell
kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath='{.data.password}' | base64 -d
```

Or check the server logs:

```powershell
docker logs argocd-server | findstr password
```

## Manual Cleanup

If needed, you can manually clean up everything:

```powershell
# Stop Docker services
docker-compose down -v

# Remove Kubernetes resources
kubectl delete namespace argocd

# Remove any leftover CRDs
kubectl delete crd applications.argoproj.io
kubectl delete crd appprojects.argoproj.io
```

## Next Steps

Once Argo CD is running, you can:

1. Create your first application
2. Connect Git repositories
3. Deploy applications using GitOps
4. Explore the web UI features
5. Try CLI commands with `argocd` (if installed)

## Architecture

This setup provides a fully functional Argo CD environment that:

- Runs in Docker containers but manages a real Kubernetes cluster
- Uses the local Docker Desktop Kubernetes cluster
- Provides the same features as a production Argo CD installation
- Is perfect for learning and development

The containers connect to your local Kubernetes cluster using the mounted kubeconfig, giving them the same access you have with kubectl.

## Learning Resources

- [Official Argo CD Documentation](https://argo-cd.readthedocs.io/)
- [Argo CD Getting Started Guide](https://argo-cd.readthedocs.io/en/stable/getting_started/)
- [GitOps Principles](https://www.gitops.tech/)

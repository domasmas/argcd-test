# Deploy .NET App with Argo CD GitOps

This exercise demonstrates GitOps deployment of a simple .NET web application using Argo CD connected to this Git repository.

## Prerequisites

- Local Argo CD instance running (from previous exercise: `.\setup.ps1`)
- This Git repository accessible (public or configured in Argo CD)
- Docker Desktop with Kubernetes enabled

**💡 Tip:** If you haven't set up ArgoCD yet, go to `practise/argo-cd-local/` and run `.\setup.ps1` first.

## What You'll Learn

- How to create an Argo CD application via the UI
- How GitOps connects Git repositories to Kubernetes deployments
- How to monitor and sync applications in Argo CD
- The GitOps workflow: Git commit → Argo CD sync → Kubernetes deployment

## Exercise Structure

This exercise uses a pre-built ASP.NET sample application from Microsoft's official container registry.

```
dotnet-app-deployment/
├── k8s/                     # Kubernetes manifests (GitOps source)
│   ├── deployment.yaml      # App deployment using public image
│   ├── service.yaml         # Service to expose app
│   └── kustomization.yaml   # Kustomize config
├── argocd-app.yaml          # Argo CD application definition
└── README.md               # This file
```

**Note:** We're using `mcr.microsoft.com/dotnet/samples:aspnetapp` - a publicly available ASP.NET sample app from Microsoft.

## Step-by-Step GitOps Instructions

### Step 1: Understand the Application Structure

This repository contains a complete GitOps setup:

```
practise/dotnet-app-deployment/
├── app/                     # .NET application source code
│   ├── Program.cs           # Minimal web app (containerized)
│   ├── MyApp.csproj         # Project file
│   └── Dockerfile           # Container definition
└── k8s/                     # Kubernetes manifests (GitOps source)
    ├── deployment.yaml      # App deployment
    ├── service.yaml         # Service to expose app
    └── kustomization.yaml   # Kustomize config
```

The `k8s/` folder is what Argo CD will monitor for changes.

### Step 2: Create an Argo CD Application via UI

1. **Open Argo CD UI:** http://localhost:30088
2. **Login:** username: `admin`, password: `<from setup script output>`
3. **Click "NEW APP"** (top left)

### Step 3: Configure the Application

Fill in these details in the "NEW APPLICATION" form:

**GENERAL**

- **Application Name:** `dotnet-gitops-app`
- **Project Name:** `default`
- **Sync Policy:** `Manual` (we'll sync manually first)

**SOURCE**

- **Repository URL:** `https://github.com/yourusername/yourrepo`
  _(Replace with your actual Git repository URL where this code lives)_
- **Revision:** `HEAD` (or `main`/`master` branch)
- **Path:** `practise/dotnet-app-deployment/k8s`

**DESTINATION**

- **Cluster URL:** `https://kubernetes.default.svc`
- **Namespace:** `default`

**KUSTOMIZE** (this section should appear automatically)

- Leave all fields empty (defaults are fine)

4. **Click "CREATE"**

### Step 4: Initial Sync

After creating the application:

1. You'll see the app in `OutOfSync` status (this is normal)
2. **Click on your application** to view details
3. You'll see the resource tree showing Deployment and Service
4. **Click "SYNC"** button
5. **Click "SYNCHRONIZE"** to confirm

### Step 5: Monitor the Deployment

Watch the Argo CD UI as it:

- Creates the Deployment
- Creates the Service
- Shows pod status as it starts up
- Reports "Healthy" when everything is running

### Step 6: Access Your Application

Once the sync is complete and showing "Healthy":

**🌐 Access your app at:** http://localhost:30080

You should see Microsoft's ASP.NET sample application with a welcome page.

## Experience the GitOps Workflow

### Making Changes (GitOps in Action)

Now let's see the real power of GitOps:

1. **Edit the application** in your Git repository:

   - Open `practise/dotnet-app-deployment/k8s/deployment.yaml`
   - Change `replicas: 1` to `replicas: 2`
   - Commit and push the change

2. **Watch Argo CD detect the change:**

   - In the Argo CD UI, your app will show as `OutOfSync`
   - The diff will show the replica change

3. **Sync the change:**

   - Click "SYNC" to apply the change
   - Watch as Argo CD creates a second pod

4. **Verify the result:**
   - `kubectl get pods` should show 2 running pods
   - Your app is still accessible at http://localhost:30080

## Understanding the GitOps Components

### The .NET Application (Pre-built)

We're using Microsoft's official ASP.NET sample application:

- **Image:** `mcr.microsoft.com/dotnet/samples:aspnetapp`
- **What it contains:** A sample ASP.NET Core web application
- **Why this works:** It's a publicly available image that doesn't require building

### Kubernetes Manifests (What Argo CD Watches)

The `k8s/` folder contains the declarative configuration:

- **deployment.yaml:** Defines the app deployment using the Microsoft sample image
- **service.yaml:** Exposes the app via NodePort on port 30080
- **kustomization.yaml:** Groups resources for Kustomize processing

**Key Point:** Argo CD watches the `k8s/` folder in your Git repository and ensures your cluster matches what's defined there.

## Troubleshooting

**"Repository not found" error:**

- Make sure you've pushed this repository to GitHub/GitLab
- Verify the repository URL is correct and publicly accessible
- For private repos, you'll need to configure credentials in Argo CD

**App stuck in "Progressing" state:**

- Check if Docker Desktop Kubernetes is running: `kubectl get nodes`
- Verify the image can be pulled: `kubectl describe pod <pod-name>`

**Can't access the app:**

- Check if the service is created: `kubectl get svc`
- Verify pods are running: `kubectl get pods`
- Ensure port 30080 is not blocked

**Sync fails:**

- Check the path in your Argo CD app configuration
- Verify kustomization.yaml is valid: `kubectl kustomize k8s/`

## Clean Up

When you're finished with the exercise:

**Delete the application in Argo CD:**

1. Go to the Argo CD UI
2. Click on your application
3. Click "DELETE" and confirm

Or use kubectl:

```bash
kubectl delete application dotnet-gitops-app -n argocd
```

## What You've Learned

✅ **GitOps Workflow:** Git repository as the single source of truth  
✅ **Argo CD UI:** Creating and managing applications  
✅ **Declarative Deployment:** Kubernetes manifests define desired state  
✅ **Sync Process:** How changes in Git become changes in Kubernetes  
✅ **Monitoring:** Observing application health and sync status

## Next Steps

- Enable **automatic sync** for continuous deployment
- Try **rollbacks** using Argo CD's history feature
- Experiment with **different sync policies**
- Create **multiple environments** (dev/staging/prod) with overlays
- Set up **webhook notifications** from your Git repository

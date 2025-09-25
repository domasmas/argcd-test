# [cite\_start]Kubernetes & Argo CD Team Learning Day – Session Plan [cite: 1]

## [cite\_start]Session Overview and Agenda [cite: 2]

[cite\_start]**Goal:** By the end of this 3-hour session, the team will understand basic Kubernetes concepts and gain hands-on experience with Argo CD (a GitOps continuous delivery tool). [cite: 3]
[cite\_start]We will cover how Argo CD works, daily operations (sync, rollback, health, self-healing), and practice deploying a simple .NET web application using Argo CD on a local Kubernetes cluster. [cite: 4]

[cite\_start]**Audience:** Teammates with very little prior Kubernetes/ArgoCD experience (beginners). [cite: 5]

[cite\_start]**Format:** First half is presentation (theory), second half is hands-on exercises. [cite: 6]
[cite\_start]Team members will take turns (“round-robin”) performing tasks in the live demo environment (Docker Desktop’s local K8s cluster on a laptop). [cite: 7]

[cite\_start]**Tools/Prerequisites:** Docker Desktop (with Kubernetes enabled) on host machine, Visual Studio Code for editing files, .NET SDK (to create a sample app), and (optional) a Docker Hub account for pushing images. [cite: 8]
[cite\_start]Internet access is assumed for pulling images and using GitHub for a repo. [cite: 9]
[cite\_start]Everything will be done **locally** on the presenter’s machine (no cloud cluster needed). [cite: 10]

### [cite\_start]Proposed 3-Hour Agenda: [cite: 11]

1.  [cite\_start]**Introduction & Overview (10 min):** Objectives of the session and what the team will learn. [cite: 12]
2.  [cite\_start]**Kubernetes Basics (20 min):** Brief introduction to Kubernetes (clusters, pods, services, etc.) – just enough to contextualize the hands-on. [cite: 13]
3.  [cite\_start]**GitOps and Argo CD Introduction (20 min):** Explain GitOps principles and how Argo CD leverages GitOps for Kubernetes deployments. [cite: 14]
4.  [cite\_start]**How Argo CD Works & Key Features (25 min):** Explain Argo CD workflow, syncing mechanism, rollbacks, health checks, self-healing, and integration with tools like Kustomize and Argo Rollouts with examples. [cite: 15]
5.  [cite\_start]***(Optional break – 10 min)*** [cite: 16]
6.  [cite\_start]**Hands-On Setup (15 min):** Enable local K8s in Docker Desktop, install Argo CD on cluster, and prepare the environment for exercises. [cite: 17]
7.  [cite\_start]**Hands-On Exercises (\~75 min total):** Team members take turns to perform: [cite: 18]
      * [cite\_start]Creating a sample .NET web app and containerizing it. [cite: 19]
      * [cite\_start]Writing Kubernetes manifests (using Kustomize for customization) for the app and pushing to a Git repository. [cite: 20]
      * [cite\_start]Creating an Argo CD Application to deploy the app. [cite: 21]
      * [cite\_start]Demonstrating app sync, update (new version), rollback, and Argo CD’s self-healing (auto-sync). [cite: 22]
      * (Each exercise is detailed in the “Hands-On Exercises” section below with step-by-step instructions.) [cite\_start][cite: 23]
8.  [cite\_start]**Wrap-up and Q\&A (10 min):** Recap key takeaways, answer questions. [cite: 24]

## [cite\_start]Part 1: Conceptual Overview (Theory Presentation) [cite: 25]

### [cite\_start]Kubernetes Basics – What & Why [cite: 26]

  * [cite\_start]**What is Kubernetes (K8s)?** Kubernetes is an open-source **container orchestration** platform designed to automate the deployment, scaling, and management of containerized applications[1]. [cite: 27]
  * [cite\_start]In simpler terms, Kubernetes helps you run and manage many Docker containers across a cluster of machines without manual intervention. [cite: 28]
  * [cite\_start]It’s the de facto standard for running containerized apps in production, capable of handling tasks like starting/stopping containers, restarting crashed applications, scaling out/in based on load, and more. [cite: 29]
  * [cite\_start]**Cluster, Nodes, and Pods:** A Kubernetes **cluster** consists of one or more worker machines (VMs or bare metal), called **nodes**. [cite: 30] [cite\_start]The cluster is managed by a control plane (which makes scheduling and scaling decisions). [cite: 31] [cite\_start]Applications in Kubernetes run inside **pods** – which are the smallest deployable units and typically contain one container (e.g. a Docker container) each. [cite: 32] [cite\_start]If a pod (or the app inside it) fails, Kubernetes can automatically replace it (basic **self-healing** at the infrastructure level). [cite: 33]
  * [cite\_start]**Deployments:** In Kubernetes, a **Deployment** is a higher-level object that ensures a specified number of pods are running. [cite: 34] [cite\_start]You declare your desired state (for example, “I want 3 instances of this web app running”) and the Deployment controller will create or terminate pods to match that state. [cite: 35] [cite\_start]Deployments also make it easy to perform rolling updates (deploying a new version of an app gradually) and rollbacks if needed. [cite: 36]
  * [cite\_start]**Services:** Pods have dynamic lifecycles (they can be recreated or rescheduled), so their IPs aren’t stable. [cite: 37] [cite\_start]A **Service** provides a stable networking endpoint to access a set of pods. [cite: 38] [cite\_start]For example, a Service of type `ClusterIP` gives an internal cluster address for other services to call, and a Service of type `NodePort` or `LoadBalancer` exposes the application to external clients. [cite: 39] [cite\_start]This is how we’ll reach our sample .NET app later. [cite: 40] [cite\_start]Kubernetes can also load-balance requests across multiple pod instances through Services. [cite: 41]
  * [cite\_start]**Why Kubernetes?** It automates many aspects of running containers in production: deployment, scaling, load-balancing, and recovery[2][3]. [cite: 42] [cite\_start]This reduces downtime and manual effort – e.g., if a node (machine) dies, Kubernetes moves pods to healthy nodes; [cite: 43] [cite\_start]if traffic spikes, it can scale out more pods; if a pod crashes, it restarts it. [cite: 44] [cite\_start]All these capabilities are declaratively driven (you describe the desired state in YAML manifests, and Kubernetes continuously works to maintain that state). [cite: 45]

### [cite\_start]GitOps Principles and Argo CD Intro [cite: 46]

  * [cite\_start]**What is GitOps?** **GitOps** is an operational paradigm (within DevOps) that uses Git as the single source of truth for infrastructure and application configurations[4]. [cite: 47] [cite\_start]All desired state (like Kubernetes manifests) is stored declaratively in Git. [cite: 48] [cite\_start]Automated agents (deploy tools) continuously reconcile the actual state of the system to match the state defined in Git[4]. [cite: 49] [cite\_start]In practice, this means any change to infrastructure/app config is done via a Git commit/merge, and a tool will deploy those changes to the environment. [cite: 50] [cite\_start]GitOps effectively decouples CI and CD: CI (Continuous Integration) pipeline builds artifacts and updates manifest files, and a GitOps CD tool notices the change and deploys it[5]. [cite: 51]
  * [cite\_start]**Advantages of GitOps:** Using Git as the source of truth brings many benefits. [cite: 52]
      * [cite\_start]All changes are version-controlled and auditable (every change has a git commit history). [cite: 53]
      * [cite\_start]You can **roll back** easily by reverting a commit in Git, which triggers the system to revert to the previous state[6]. [cite: 54]
      * [cite\_start]Git workflows (pull requests, code reviews) can be used to manage infrastructure changes, improving collaboration and reducing risk[6]. [cite: 55]
      * [cite\_start]Continuous reconciliation means drift (manual changes that diverge from Git) is corrected, resulting in **self-healing** infrastructure[7]. [cite: 56]
      * [cite\_start]Also, developers don’t need direct access to the cluster – they just commit to Git, and the operator (like Argo CD) applies it, enhancing security and consistency across environments[8]. [cite: 57]
  * [cite\_start]**What is Argo CD?** Argo CD is a popular open-source tool that implements GitOps for Kubernetes. [cite: 58] [cite\_start]It’s a **declarative GitOps continuous delivery** platform for deploying apps to K8s. [cite: 59] [cite\_start]In essence, Argo CD monitors a Git repository for changes to K8s manifests and ensures the Kubernetes clusters reflect those manifests[9][10]. [cite: 60] [cite\_start]It’s **pull-based**: instead of a CI pipeline pushing deployments, Argo CD **pulls** the updates from Git and applies them to the cluster[11]. [cite: 61] [cite\_start]Argo CD runs inside Kubernetes as a controller that continuously compares the live state vs. the desired state in Git. [cite: 62] [cite\_start]If something is out of sync, it can alert and/or automatically synchronize the cluster to match the Git state. [cite: 63]
  * [cite\_start]**Argo CD and GitOps:** Argo CD essentially brings GitOps to life for Kubernetes – you declare apps in Git, and Argo CD makes sure that is what’s running. [cite: 64] [cite\_start]For example, if you update a version number in a deployment YAML in Git, Argo detects it and deploys the new version on the cluster[11]. [cite: 65] [cite\_start]If someone accidentally deletes a resource on the cluster, Argo can detect that and re-create it from Git (if auto-healing is enabled) to **self-heal** to the declared state[12]. [cite: 66]
  * [cite\_start]**Why use Argo CD?** It automates deployments, provides visibility, and ensures consistency. [cite: 67] [cite\_start]All environment changes are transparent (you can see what Git commit is currently deployed). [cite: 68] [cite\_start]It supports one-click rollbacks (to any Git commit) and easy rollouts to multiple clusters/environments from the same repo. [cite: 69] [cite\_start]In short, Argo CD makes deployments **automated, auditable, and easier to understand** by using Git and declarative configurations[13]. [cite: 70]

### [cite\_start]How Argo CD Works – Workflow and Architecture [cite: 71]

  * [cite\_start]**Argo CD GitOps workflow:** Argo CD runs as a **Kubernetes controller** inside your cluster. [cite: 72] [cite\_start]It continuously monitors your Git repository (where Kubernetes YAML manifests or Helm charts are stored) for any changes, and also watches the live state of applications on the cluster[10]. [cite: 73] [cite\_start]If the live state of the cluster deviates from what’s in Git (meaning the app is “drifting” or not up-to-date), Argo CD will mark the application `OutOfSync` and (depending on settings) can automatically apply the changes or wait for a manual sync. [cite: 74] [cite\_start]The diagram above illustrates this flow: developers commit code or config to Git, and Argo CD pulls those updates into the cluster, creating/updating Kubernetes resources as defined. [cite: 75] [cite\_start]Argo CD will **report the status** of each application – whether it’s `Synced` with Git, and whether the application is `Healthy` or not – in a web UI and CLI. [cite: 76]
  * [cite\_start]**Key points on Argo CD architecture & workflow:** [cite: 77]
      * [cite\_start]**Pull-Based Deployment:** Unlike traditional CI/CD where a pipeline pushes updates, Argo CD’s controller **pulls changes from Git**. [cite: 78] [cite\_start]It periodically (or via webhooks) checks the repo for new commits. [cite: 79] [cite\_start]When it finds changes, it fetches the latest manifests and applies them to the cluster (if auto-sync is on, this happens automatically; if not, it just flags that the app is `OutOfSync` and awaits a human to click “Sync”)[11][10]. [cite: 80]
      * [cite\_start]**Desired vs Live State:** Argo CD stores the **desired state** (from Git) and continuously compares it to the **live state** on the cluster. [cite: 81] [cite\_start]If they differ, the app is in `OutOfSync` status[10]. [cite: 82] [cite\_start]For example, if in Git you have 3 replicas for a Deployment but someone manually scaled the cluster to 4 replicas, Argo will show `OutOfSync` (actual state deviated from desired). [cite: 83] [cite\_start]This drift detection is automatic and runs continuously. [cite: 83]
      * [cite\_start]**Argo CD Application:** In Argo CD terminology, an **Application** is a custom resource that defines the source Git repo, path, target cluster, and any sync settings for a deployment. [cite: 84] [cite\_start]When we **create an Application** in Argo CD (which we will do in the exercise), we are telling Argo “please track this repo (and optionally a specific folder or Helm chart) and make sure the cluster (or a specific namespace in a cluster) matches it”. [cite: 85] [cite\_start]The Application resource in Argo CD then becomes the unit of deployment that we monitor and manage (it can contain multiple K8s resources defined in that repo path). [cite: 86]
      * [cite\_start]**User Interface and CLI:** Argo CD provides a web **UI** that visually shows a list of Applications, their sync status, health status of each component (e.g., deployments, pods), and a topology view. [cite: 87] [cite\_start]It also offers a CLI (`argocd`) for scripting and automation. [cite: 88] [cite\_start]Beginners often find the UI easier (everything can be done with clicks), but the CLI is powerful for pipelines and advanced use. [cite: 89]

### [cite\_start]Argo CD Key Features for Daily Operations [cite: 90]

[cite\_start]As a day-to-day Kubernetes deployment tool, Argo CD offers several important capabilities. [cite: 91] [cite\_start]We will touch and practice these features: [cite: 91]

  * [cite\_start]**Sync (Deploying Changes):** “Syncing” is the process of making the cluster state match the Git state. [cite: 92] [cite\_start]In manual mode, an operator triggers a Sync through the UI or CLI when ready to deploy. [cite: 93] [cite\_start]In auto-sync mode, Argo CD will do this automatically whenever it detects changes in Git. [cite: 94] [cite\_start]During a sync, Argo CD applies the Kubernetes manifests (create/update/delete resources) to move the app from `OutOfSync` to `Synced`. [cite: 95] [cite\_start]It ensures the resources reach the desired state (it waits for Kubernetes to finish rolling out deployments, etc., before marking the app `Synced` and `Healthy`). [cite: 96] [cite\_start]Essentially, Argo CD turns Git commits into deployed Kubernetes resources in a controlled way. [cite: 97]
  * [cite\_start]**Observed Health Status:** Argo CD monitors the health of applications and their Kubernetes resources. [cite: 98] [cite\_start]It knows how to assess the health of different resource types (for example, a Deployment is `Healthy` when the desired number of pods are running and available; it’s `Progressing/Degraded` if pods are failing to come up or crash looping). [cite: 99] [cite\_start]The Argo UI will show a green “Healthy” status when all is well, or red “Degraded” if something is wrong (e.g., a pod is unhealthy). [cite: 100] [cite\_start]This helps you quickly see if your application deployment is successful beyond just applying YAML. [cite: 101] [cite\_start]Argo uses Kubernetes APIs to check resource conditions for this health analysis[14]. [cite: 102]
  * [cite\_start]**Rollbacks (Reverting to Previous Version):** If a new release has issues, Argo CD makes rollbacks easy. [cite: 103] [cite\_start]Since Argo CD tracks the deployment history (by Git commits), you can instruct it to redeploy a prior Git revision. [cite: 104] [cite\_start]In the Argo CD UI, there’s a **History and Rollback** panel where you can see past commits/versions; [cite: 105] [cite\_start]by selecting an earlier commit and clicking “Rollback”, Argo will apply that version’s manifests, effectively reverting the app to the previous state[15][16]. [cite: 106] (Under the hood, this is similar to doing a `git revert` and sync, or choosing a specific Git SHA to sync to.) [cite\_start][cite: 107] [cite\_start]One important note: if auto-sync is enabled, you typically disable it briefly when performing a rollback, to avoid Argo trying to “correct” the rollback as a divergence[17]. [cite: 107] [cite\_start]We’ll demonstrate a rollback in our exercise by rolling back the app to an older version. [cite: 108]
  * [cite\_start]**Automated Sync & Self-Healing:** In Argo CD’s settings, you can enable **Automatic Sync** (Argo will apply every new Git commit immediately) and **Self-Heal** (Argo will also continuously correct any drift in the live cluster even if no new commit – for instance, if someone manually changes or deletes a resource). [cite: 109] [cite\_start]With **Self-Heal** on, Argo becomes a true GitOps operator that ensures the cluster **always** matches Git. [cite: 110] [cite\_start]For example, if someone accidentally deletes an application’s pod or modifies a ConfigMap, Argo will detect the difference (live state \!= desired state in Git) and reapply the last known good config from Git to “heal” the app[12]. [cite: 111] [cite\_start]This can prevent configuration drift and outages – the system actively fights entropy. [cite: 112] [cite\_start]We will try this out by enabling auto-sync/self-heal and then deleting a resource to see Argo auto-recreate it. [cite: 113]
  * [cite\_start]**Pruning and Garbage Collection:** Another useful feature (likely mentioned but possibly not needed in our simple demo) is **pruning**. [cite: 114] [cite\_start]If a resource was previously deployed but then its manifest is removed from Git, Argo can automatically delete it from the cluster (to avoid orphaned resources). [cite: 115] [cite\_start]This is an option with auto-sync (enabled via “Prune” flag)[18]. [cite: 116] [cite\_start]It ensures the cluster doesn’t have leftover resources that are no longer in Git. [cite: 117] [cite\_start]We might not explicitly cover this in the exercise, but it’s good to be aware of as a daily operation when applications evolve or resources are removed. [cite: 118]
  * [cite\_start]**Multi-Cluster Deployments:** Argo CD can manage multiple clusters from one central installation (you can register external clusters). [cite: 119] [cite\_start]In our case, we’ll only use the local cluster (the one Argo is running in). [cite: 120] [cite\_start]By default, Argo CD is configured to manage the cluster it’s installed on (no extra steps needed for us)[19]. [cite: 121] [cite\_start]For larger environments, you could connect Argo CD to staging, prod clusters etc., but that’s beyond today’s scope. [cite: 122]
  * [cite\_start]**Progressive Delivery with Argo Rollouts:** Argo Rollouts is an Argo project extension that enables advanced deployment strategies like canary (gradual traffic shifting to new versions) and blue-green deployments. [cite: 122] [cite\_start]It integrates with Argo CD to provide automated analysis, metrics-driven rollouts, and rollback capabilities for safer, controlled releases. [cite: 122] [cite\_start]This is useful for production environments where you want to minimize risk during updates. [cite: 122]

[cite\_start]**Summary:** Argo CD automates Kubernetes app deployments using Git as the source of truth. [cite: 123] [cite\_start]It provides an easy way to keep applications in sync with config, supports quick rollbacks, shows health status, and even keeps your cluster state correct automatically with auto-sync[20]. [cite: 124] [cite\_start]These capabilities lead to safer, more repeatable deployments and fewer “config drift” issues in day-to-day operations. [cite: 125]

## [cite\_start]Part 2: Hands-On Exercises (Practical Session) [cite: 126]

[cite\_start]In this section, we walk through a series of practical exercises to cement the concepts. [cite: 127] [cite\_start]We’ll set up a local Kubernetes cluster on Docker Desktop, install Argo CD, deploy a simple .NET web application through Argo CD, and then perform various operations (sync, update, rollback, self-heal). [cite: 128] [cite\_start]Each exercise is detailed step-by-step. [cite: 129] [cite\_start]Team members can take turns driving each part of the live demo. [cite: 129]

[cite\_start]**Note:** All commands below are assumed to be run in a terminal on the host machine. [cite: 130] [cite\_start]We also assume Docker Desktop is installed and running on your machine, and that you have a web browser (for Argo CD UI) and VS Code (for editing files) available. [cite: 131]

### [cite\_start]Exercise 1: Setting Up a Local Kubernetes Cluster (Docker Desktop) [cite: 132]

  * [cite\_start]**Purpose:** Ensure a Kubernetes cluster is running locally for our experiments. [cite: 133] [cite\_start]We will use Docker Desktop’s built-in Kubernetes (no separate Minikube installation needed). [cite: 134]
  * [cite\_start]**Enable Kubernetes in Docker Desktop:** Open Docker Desktop settings and navigate to “Kubernetes”. [cite: 135] [cite\_start]Check the option to enable the Kubernetes cluster and **Apply/Restart**. [cite: 136] [cite\_start]Wait a couple of minutes for the Kubernetes cluster to start. [cite: 137] [cite\_start]You should see a green ‘Kubernetes running’ status in Docker Desktop. [cite: 138] [cite\_start]If Kubernetes was already enabled, great – you’ll see a Kubernetes context named “docker-desktop” in your kubeconfig by default. [cite: 139]
  * [cite\_start]**Verify kubectl access:** Open a terminal (VS Code terminal or command prompt) and run: [cite: 140]
    ```bash
    kubectl config get-contexts
    ```
    [cite\_start][cite: 141]
    [cite\_start]You should see “docker-desktop” listed (and starred as current context). [cite: 142] [cite\_start]Also check: [cite: 142]
    ```bash
    kubectl get nodes
    ```
    [cite\_start][cite: 143]
    [cite\_start]This should return at least one node (e.g., `docker-desktop` or `docker-desktop-control-plane`) in “Ready” status. [cite: 144] [cite\_start]This confirms your local K8s cluster is up. [cite: 145]
  * [cite\_start]**(Optional) Set context namespace:** For convenience, you can set your current context’s default namespace to something like `default` or later we’ll use `argocd`. [cite: 146] [cite\_start]For now, not critical – but if you’d like, do: [cite: 147]
    ```bash
    kubectl config set-context --current --namespace=default
    ```
    [cite\_start][cite: 148]
    (We will create an `argocd` namespace shortly during Argo CD install.) [cite\_start][cite: 149]
  * [cite\_start]Now we have a working Kubernetes cluster locally. [cite: 150] [cite\_start]Next, we’ll deploy Argo CD onto this cluster. [cite: 150]

### [cite\_start]Exercise 2: Installing Argo CD on Kubernetes [cite: 151]

  * [cite\_start]**Purpose:** Install Argo CD into the cluster so we can use it to manage our app deployments. [cite: 152] [cite\_start]We’ll use the official Argo CD manifest to keep it simple. [cite: 153]
  * [cite\_start]**Create `argocd` namespace:** Argo CD’s components will live in a separate namespace (recommended). [cite: 154] [cite\_start]Run: [cite: 154]
    ```bash
    kubectl create namespace argocd
    ```
    [cite\_start][cite: 155]
    [cite\_start]This creates a new namespace called `argocd` for our Argo CD installation[21]. [cite: 156]
  * [cite\_start]**Apply Argo CD install manifest:** The Argo project provides an all-in-one manifest yaml. [cite: 157] [cite\_start]Apply it to install Argo CD: [cite: 157]
    ```bash
    kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
    ```
    [cite\_start][cite: 158]
    [cite\_start]This command downloads the Argo CD installation YAML and creates all the necessary resources (deployments, pods, services, etc.) in the `argocd` namespace[21]. [cite: 159] [cite\_start]It may take a minute or two to pull the images for Argo CD components (api-server, repo-server, controller, UI server, Redis, etc.). [cite: 160]
  * [cite\_start]**Check Argo CD pods status:** To confirm all Argo CD components are running, execute: [cite: 161]
    ```bash
    kubectl get pods -n argocd
    ```
    [cite\_start][cite: 162]
    [cite\_start]You should see pods like `argocd-server`, `argocd-repo-server`, `argocd-application-controller`, `argocd-redis`, etc. [cite: 163] [cite\_start]Wait until all pods show STATUS as “Running” (and READY 1/1 or 2/2 for some). [cite: 163] [cite\_start]If some are still pulling images, give it a moment. [cite: 164]
  * [cite\_start]**Access the Argo CD API server (UI):** By default, Argo CD’s API server is not exposed outside the cluster (for security). [cite: 165] [cite\_start]In our local setup, we can use `kubectl port-forward` to expose it on localhost. [cite: 166] [cite\_start]In a separate terminal, run: [cite: 166]
    ```bash
    kubectl port-forward svc/argocd-server -n argocd 8080:443
    ```
    [cite\_start][cite: 167]
    [cite\_start]This forwards your local port 8080 to the Argo CD server’s HTTPS port. [cite: 168] [cite\_start]Now you can open a web browser to `https://localhost:8080` and you should see the Argo CD UI login screen[22][23]. [cite: 169] (Ignore any browser certificate warning – Argo uses a self-signed cert by default.) [cite\_start][cite: 170]
  * [cite\_start]**Login to Argo CD:** We need the initial admin password. [cite: 171] [cite\_start]The username is `admin`. [cite: 171] [cite\_start]The default password was auto-generated when we installed Argo CD. [cite: 172] [cite\_start]To retrieve it, run: [cite: 172]
    ```bash
    kubectl -n argocd get secret argocd-initial-admin-secret \  -o jsonpath="{.data.password}" | base64 -d && echo
    ```
    [cite\_start][cite: 173]
    [cite\_start]This will output a random string (the admin password). [cite: 174] [cite\_start]Copy that. [cite: 174] [cite\_start]At the Argo CD web UI login, enter username `admin` and this password to login. [cite: 175]
  * [cite\_start]🎉 You should now see the Argo CD dashboard (which currently has no applications configured). [cite: 176]
  * [cite\_start]**Tip:** It’s recommended to change the default password after first login (Argo CD UI \> user settings or via CLI), but for this workshop it’s fine to use default. [cite: 177]
  * [cite\_start]Now we have Argo CD up and running locally. [cite: 178] [cite\_start]It is connected to our cluster (since Argo CD is running **inside** the cluster, it automatically can manage that same cluster by default[19]). [cite: 178] [cite\_start]We are ready to deploy an application through Argo CD. [cite: 179]

### [cite\_start]Exercise 3: Creating a Sample .NET Web Application [cite: 180]

  * [cite\_start]**Purpose:** Set up a very simple .NET application that we will deploy to Kubernetes. [cite: 181] [cite\_start]We’ll create a new .NET project and a Docker image for it. [cite: 182]
  * [cite\_start]**Create a new .NET web app project:** Using the .NET SDK, create a minimal web app. [cite: 183] [cite\_start]In a suitable directory on your machine, run: [cite: 184]
    ```bash
    dotnet new web -o MyWebApp
    ```
    [cite\_start][cite: 185]
    [cite\_start]This uses the **ASP.NET Core minimal web template**, which produces a basic web app that listens on port 5000 and returns “Hello World” (or similar) on the root URL. [cite: 186] [cite\_start]Alternatively, you can use `dotnet new webapp -o MyWebApp` for a Razor Pages app if you prefer an MVC structure, but the minimal web is simplest for now. [cite: 187]
  * [cite\_start]**Examine the app:** A new folder `MyWebApp` is created. [cite: 188] [cite\_start]Open it in VS Code. [cite: 188] [cite\_start]Notice the `Program.cs` which sets up a web server and likely has a default route. [cite: 189] [cite\_start]We can customize the message to confirm deployments. [cite: 190] [cite\_start]Edit `Program.cs` to change the response message: for example, replace `app.MapGet("/", () => "Hello World!");` [cite: 190] [cite\_start]with: [cite: 191]
    ```csharp
    app.MapGet("/", () => "Hello from Argo CD deployment!");
    ```
    [cite\_start][cite: 192]
    [cite\_start]Save the file. [cite: 193]
  * [cite\_start]**Create a `Dockerfile`:** In the `MyWebApp` directory, add a file named `Dockerfile` (no extension). [cite: 194] [cite\_start]This will define how to containerize the .NET app. [cite: 195] [cite\_start]For simplicity, we can use a multi-stage build: [cite: 195]
    ```dockerfile
    # Use the official .NET SDK image to build the app
    FROM mcr.microsoft.com/dotnet/sdk:7.0 AS build
    WORKDIR /src
    COPY . .
    RUN dotnet publish -c Release -o /app

    # Use the smaller runtime image for final container
    FROM mcr.microsoft.com/dotnet/aspnet:7.0 AS final
    WORKDIR /app
    COPY --from=build /app ./

    # Instruct Kestrel to listen on port 80
    ENV ASPNETCORE_URLS=http://+:80
    EXPOSE 80

    # Run the app
    ENTRYPOINT ["dotnet", "MyWebApp.dll"]
    ```
    [cite\_start][cite: 196]
    [cite\_start][cite: 197]
    [cite\_start](This Dockerfile builds the .NET project and then packages it in a lightweight runtime image. [cite: 198] [cite\_start]We set the app to listen on port 80 for convenience.) [cite: 198]
  * [cite\_start]**Build the Docker image:** In the terminal, ensure you’re in the `MyWebApp` directory (where the `Dockerfile` is). [cite: 199] [cite\_start]Run: [cite: 199]
    ```bash
    docker build -t mywebapp:v1 .
    ```
    [cite\_start][cite: 200]
    [cite\_start]This will compile the app and create a Docker image tagged `mywebapp:v1` in your local Docker registry. [cite: 201] [cite\_start]Verify the image exists by running `docker images | grep mywebapp`. [cite: 202] [cite\_start]You should see `mywebapp` with the tag `v1`. [cite: 202] [cite\_start]You can also test-run the container locally (optional): [cite: 203]
    ```bash
    docker run -d -p 5000:80 mywebapp:v1
    ```
    [cite\_start][cite: 204]
    [cite\_start]Then browse to `http://localhost:5000` to see the "Hello from Argo CD deployment\!" message. [cite: 205] [cite\_start]This is just to verify the image works. [cite: 206] [cite\_start]You can stop the container after checking. [cite: 206]
  * [cite\_start]**Push image to a registry (if required):** Since we are using Docker Desktop’s local K8s, we have two options for the Kubernetes deployment to get this image: [cite: 207]
      * [cite\_start]**Option A: Use local image:** Docker Desktop’s Kubernetes can directly use images from your local Docker daemon. [cite: 208] [cite\_start]As long as the image tag `mywebapp:v1` is present locally, a Kubernetes pod on Docker Desktop can pull it (it actually just finds it locally without needing an external registry). [cite: 209] [cite\_start]This usually works out of the box for Docker Desktop (which uses the same underlying Docker daemon). [cite: 210] [cite\_start]We’ll proceed with this approach for simplicity – meaning we don’t need to push the image anywhere. [cite: 211] [cite\_start]We will just reference `mywebapp:v1` in our Kubernetes manifest. [cite: 212]
      * [cite\_start]**Option B: Push to Docker Hub (or another registry):** If for some reason local image usage doesn’t work or you want to simulate a real environment, you could push the image. [cite: 213] [cite\_start]For example, tag and push to Docker Hub: [cite: 214]
        ```bash
        docker tag mywebapp:v1 <your-dockerhub-username>/mywebapp:v1
        docker push <your-dockerhub-username>/mywebapp:v1
        ```
        [cite\_start][cite: 215]
        [cite\_start]Then in Kubernetes manifests you’d use the full image name (and ensure the cluster can access Docker Hub, which it can for public images). [cite: 216]
  * [cite\_start]We’ll assume Option A (local image) to avoid needing internet or credentials. [cite: 217]
  * [cite\_start]Now we have a container image for our application (version 1). [cite: 218] [cite\_start]Next, we’ll create Kubernetes manifest files for deploying this app. [cite: 219]

### [cite\_start]Exercise 4: Writing Kubernetes Manifests for the Application [cite: 220]

  * [cite\_start]**Purpose:** Define the Kubernetes resources (Deployment and Service) to run the .NET app in the cluster. [cite: 221] [cite\_start]We will create these manifests in YAML and later put them in Git for Argo CD to use. [cite: 222] [cite\_start]We will also introduce Kustomize for customizing these manifests across environments. [cite: 222]
  * [cite\_start]**Create a Kubernetes deployment YAML:** In a new subfolder (for example, create a folder `k8s-manifests` in the project or elsewhere), create a file `deployment.yaml`. [cite: 223] [cite\_start]This will describe a Deployment for our `MyWebApp`. [cite: 224] [cite\_start]For example: [cite: 224]
    ```yaml
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: mywebapp-deployment
      labels:
        app: mywebapp
    spec:
      replicas: 1
      selector:
        matchLabels:
          app: mywebapp
      template:
        metadata:
          labels:
            app: mywebapp
        spec:
          containers:
          - name: mywebapp
            image: mywebapp:v1               # Image name (we built this locally)
            imagePullPolicy: IfNotPresent    # Use local image if available (avoid pulling)
            ports:
            - containerPort: 80              # The app listens on port 80 as set in Dockerfile
    ```
    [cite\_start][cite: 225]
    [cite\_start][cite: 226]
    [cite\_start]Key points: we set `replicas: 1` (just one pod for now), and ensure the selector matches the pod labels. [cite: 227] [cite\_start]The container spec uses `mywebapp:v1` image (which our cluster will find locally). [cite: 228] [cite\_start]`imagePullPolicy: IfNotPresent` ensures Kubernetes will use a local image if it exists (it won’t try to pull from a registry every time). [cite: 229]
  * [cite\_start]**Create a Service YAML:** In the same folder, create `service.yaml` to expose the Deployment: [cite: 230]
    ```yaml
    apiVersion: v1
    kind: Service
    metadata:
      name: mywebapp-service
    spec:
      type: NodePort
      selector:
        app: mywebapp
      ports:
      - port: 80          # Service port (target port on pods)
        targetPort: 80    # container port to send traffic to
        nodePort: 30007   # (NodePort to expose on localhost for Docker Desktop)
    ```
    [cite\_start][cite: 231]
    [cite\_start]We choose `NodePort` service so we can easily hit the app from our host. [cite: 232] [cite\_start]Here, we fix the `nodePort` to `30007` (just an arbitrary high port) – Docker Desktop will map this, allowing us to access the app at `http://localhost:30007`. [cite: 233] [cite\_start]The Service selector `app: mywebapp` ties it to our Deployment’s pods. [cite: 234]
  * [cite\_start]**Introduce Kustomize:** Kustomize allows us to customize Kubernetes manifests without editing the base YAML files. [cite: 234] [cite\_start]Create a `kustomization.yaml` file in the same folder: [cite: 234]
    ```yaml
    apiVersion: kustomize.config.k8s.io/v1beta1
    kind: Kustomization
    resources:
    - deployment.yaml
    - service.yaml
    ```
    [cite\_start][cite: 234]
    [cite\_start]This file lists the resources to include. [cite: 234] [cite\_start]You can use `kubectl kustomize .` to generate the final YAML, or Argo CD can apply it directly. [cite: 234] [cite\_start]Kustomize is useful for environment-specific patches (e.g., changing replicas or images per environment). [cite: 234]
  * [cite\_start]**Alternative:** We could use a `LoadBalancer` service type. [cite: 235] [cite\_start]In Docker Desktop’s Kubernetes, a `LoadBalancer` might require an extra setup (like MetalLB) or it might route to localhost automatically. [cite: 235] [cite\_start]To keep it simple, `NodePort` works reliably for local clusters. [cite: 236]
  * [cite\_start]**Namespace consideration:** For now, these manifests have no namespace specified, so they will deploy to the **default** namespace of the cluster (or whichever namespace ArgoCD deploys into if specified). [cite: 237] [cite\_start]We can deploy to the `default` namespace to keep it simple. [cite: 238] [cite\_start]Argo CD itself is in `argocd` namespace, but our app can be in `default` or any other (Argo can deploy to all namespaces by default). [cite: 239] [cite\_start]We will use the `default` namespace for our app. [cite: 240]
  * [cite\_start]At this point, we have two YAML files defining our app’s Kubernetes components. [cite: 241] [cite\_start]The next step is to put these under version control (Git), since Argo CD will watch a Git repository for them. [cite: 242]

### [cite\_start]Exercise 5: Setting Up a Git Repository for GitOps [cite: 243]

  * [cite\_start]**Purpose:** Create a Git repository to store our Kubernetes manifests (the desired state). [cite: 244] [cite\_start]Argo CD will monitor this repo for changes. [cite: 245]
  * [cite\_start]**Initialize a Git repository:** If you have Git installed, navigate to the folder containing your manifest YAML files (e.g., the `k8s-manifests` folder or wherever you put them). [cite: 246] [cite\_start]Run: [cite: 247]
    ```bash
    git init
    git add deployment.yaml service.yaml
    git commit -m "Add initial K8s manifests for MyWebApp"
    ```
    [cite\_start][cite: 248]
    [cite\_start]This creates a local git repository and commits the manifests. [cite: 249]
  * [cite\_start]**Create a remote repo (GitHub or other):** Go to GitHub (or your Git server of choice) and create a new repository, e.g., `mywebapp-config`. [cite: 250] (This could be private or public; Argo CD can handle either, though if private you’d need to setup repo access via SSH key or token – for simplicity, you can make it public for this exercise or use a personal repo with https access.) [cite\_start][cite: 251]
  * [cite\_start]**Push local repo to GitHub:** [cite: 252]
    ```bash
    git remote add origin https://github.com/<yourusername>/mywebapp-config.git
    git branch -M main
    git push -u origin main
    ```
    [cite\_start][cite: 253]
    [cite\_start]Now your `deployment.yaml` and `service.yaml` are in a GitHub repository. [cite: 254] [cite\_start]You can browse the repo to confirm the files are there. [cite: 255] [cite\_start]This repository URL and path will be used by Argo CD to fetch manifests. [cite: 256]
  * [cite\_start]**Note:** If you prefer not to use a public Git hosting, Argo CD could also sync from a local repository path, but that requires the repo to be accessible from within the cluster (which is non-trivial without setting up a local Git service). [cite: 257] [cite\_start]Using GitHub is the straightforward approach here. [cite: 258]
  * [cite\_start]Now we have: a Docker image built, Kubernetes manifests defining how to run that image, and those manifests stored in a Git repo. [cite: 259] [cite\_start]We are ready to use Argo CD to deploy the app from this Git repo to our cluster. [cite: 260]

### [cite\_start]Exercise 6: Creating an Argo CD Application to Deploy the App [cite: 261]

  * [cite\_start]**Purpose:** In this step, we will set up Argo CD to track our Git repository and deploy the application manifests to the cluster. [cite: 262] [cite\_start]This involves creating a new Application in Argo CD. [cite: 263]
  * [cite\_start]**Open Argo CD UI:** (If you closed it, remember to port-forward again as in Exercise 2 step 4). [cite: 264] [cite\_start]Log in as `admin` (with password as before). [cite: 265] [cite\_start]You should see the welcome page with “No applications yet”. [cite: 265]
  * [cite\_start]**Create New Application:** In Argo CD’s web UI, click the “+ NEW APP” button (top right). [cite: 266] [cite\_start]A form will appear to define the application. [cite: 267]
      * [cite\_start]**Application Name:** e.g., `mywebapp`. [cite: 268] (Choose any name that is unique in Argo; lowercase alphanumeric is fine.) [cite\_start][cite: 268]
      * [cite\_start]**Project:** `default` (we’ll use Argo’s default project, which is fine for now). [cite: 269]
      * [cite\_start]**Sync Policy:** keep it as `Manual` for now (we’ll manually trigger syncs; we can enable auto-sync later when demonstrating self-healing). [cite: 270]
      * [cite\_start]**Repository URL:** enter the Git repo URL where you pushed the manifests (for example, `https://github.com/<yourusername>/mywebapp-config.git`). [cite: 271]
      * [cite\_start]**Revision:** use `main` (or the branch name where your manifests are, default is `main`). [cite: 272]
      * [cite\_start]**Path:** if your manifests are at the root of the repo, put `.`; [cite: 273] [cite\_start]if you put them in a subfolder, specify that path. [cite: 274] (For example, if you stored YAMLs in `k8s-manifests` folder in the repo, put `k8s-manifests`.) [cite\_start][cite: 275]
      * [cite\_start]**Cluster:** choose “[https://kubernetes.default.svc](https://www.google.com/search?q=https://kubernetes.default.svc)” (this represents the in-cluster Kubernetes that Argo CD is already connected to)[19]. [cite: 276] [cite\_start]By default, your local cluster should be listed. [cite: 277] (If it’s not showing, ensure your Argo CD has cluster access; usually, ArgoCD auto-adds the cluster it’s installed in as “in-cluster”.) [cite\_start][cite: 277]
      * [cite\_start]**Namespace:** put `default` (since our manifests have no explicit namespace and will go to `default`). [cite: 278] [cite\_start]This tells Argo CD to deploy resources into the `default` namespace of the cluster. [cite: 279]
  * [cite\_start]**Create the app:** Click **Create**. [cite: 280] [cite\_start]Now Argo CD will register this application. [cite: 280] [cite\_start]You should see `mywebapp` appear in the UI with a status. [cite: 281] [cite\_start]Initially, it will likely show `OutOfSync` (yellow/orange state) because it detected that the desired manifests (in Git) are not yet applied to the cluster. [cite: 282]
  * [cite\_start]**Examine the app details:** Click on the application `mywebapp`. [cite: 283] [cite\_start]You’ll see a visual tree of the resources (it should list the Deployment and Service from our manifests, though they are not yet created on the cluster). [cite: 284] [cite\_start]Argo CD shows they are “Missing” (because in Git they exist but in the cluster they don’t yet) and the app state is `OutOfSync`. [cite: 285]
  * [cite\_start]**Synchronize (deploy) the application:** Click the **Sync** button. [cite: 286] [cite\_start]In the dialog, you can leave options default and confirm. [cite: 287] [cite\_start]Argo CD will now apply the Git manifests to the cluster. [cite: 288] [cite\_start]You’ll see the sync operation progress – it will say “progressing” and then hopefully “Synced” and “Healthy”. [cite: 289] [cite\_start]The Deployment will be created, which triggers Kubernetes to create a pod for our app. [cite: 290] [cite\_start]Argo CD waits until the Deployment’s rollout is complete. [cite: 291] [cite\_start]Our app is small, so within a few seconds the pod should be running. [cite: 291] [cite\_start]The Service is also created to expose the app. [cite: 292] [cite\_start]Once done, Argo CD UI should show the application as `Synced` (green) and `Healthy` (green). [cite: 293] [cite\_start]If something went wrong, it might show Degraded or an error – but for a simple app it should be fine. [cite: 294] [cite\_start]You can click the Deployment in the UI to see events or logs if needed. [cite: 295]
  * [cite\_start]At this point, Argo CD has deployed our app\! [cite: 296] [cite\_start]Kubernetes is now running the container we built, as per the manifests in Git. [cite: 296] [cite\_start]We’ll verify the app is live next. [cite: 297]

### [cite\_start]Exercise 7: Testing the Deployed Application [cite: 298]

  * [cite\_start]**Purpose:** Verify that the application is actually running and accessible as expected. [cite: 299]
  * [cite\_start]**Find the app’s pod:** Just to confirm, you can run: [cite: 300]
    ```bash
    kubectl get pods -n default
    ```
    [cite\_start][cite: 301]
    [cite\_start]You should see a pod named something like `mywebapp-deployment-xxxxxxxxx-xxxxx` in `Running` status. [cite: 302] [cite\_start]This was created by the Deployment we applied. [cite: 302]
  * [cite\_start]**Access via Service (NodePort):** Recall we made the Service type `NodePort` on port `30007`. [cite: 303] [cite\_start]Because we’re on Docker Desktop, you can access `NodePort` services at `localhost:<nodePort>`. [cite: 303] [cite\_start]Open your web browser to `http://localhost:30007`. [cite: 304] You should see the message “Hello from Argo CD deployment\!” (or whatever text you put in the `Program.cs`)[cite\_start]. [cite: 304] [cite\_start][cite: 305] [cite\_start]This confirms the app is up and the Service is routing to the pod. [cite: 305]
  * [cite\_start]If you don’t see it, troubleshoot: maybe the pod is still starting or crashed (use `kubectl logs <pod>` to see if any error, though a simple hello should be fine). [cite: 306] [cite\_start]Ensure Docker Desktop isn’t blocking the port. [cite: 307] [cite\_start]Alternatively, you could do `kubectl port-forward svc/mywebapp-service 5000:80` and then hit `http://localhost:5000` as another method. [cite: 308]
  * [cite\_start]**Observe Argo CD’s view:** In Argo UI, our app `mywebapp` should show `Healthy`/`Synced`. [cite: 309] [cite\_start]This means Argo sees that the live state matches the Git state, and Kubernetes reported the Deployment is healthy (all replicas available). [cite: 310] [cite\_start]The UI tree likely shows the Service and Deployment with green status. [cite: 311] [cite\_start]This visual confirmation is how, day-to-day, you’d quickly check if deployments are successful. [cite: 312]
  * [cite\_start]Congratulations – we have deployed our first app via Argo CD\! [cite: 313] [cite\_start]Next, we’ll simulate some typical operations: updating the app (new version), rolling back, and testing self-healing. [cite: 314]

### [cite\_start]Exercise 8: Simulating an Application Update (GitOps Deployment) [cite: 315]

  * [cite\_start]**Purpose:** Make a change to the application (new version) and see how Argo CD handles updates. [cite: 316] [cite\_start]We will update our .NET app’s code (or just output), build a new image v2, update the manifest in Git, and let Argo CD deploy it. [cite: 317]
  * [cite\_start]**Modify the application code:** Open `Program.cs` in the `MyWebApp` project again. [cite: 318] [cite\_start]Change the message string to something new, e.g., "Hello from Argo CD deployment v2\!". [cite: 319] [cite\_start]Save the file. [cite: 319]
  * [cite\_start]**Rebuild the Docker image with a new tag:** In terminal: [cite: 320]
    ```bash
    docker build -t mywebapp:v2 .
    ```
    [cite\_start][cite: 321]
    [cite\_start]This builds a new image (v2) with the updated code. [cite: 322] (For quick builds, you can use Docker’s caching, but since we changed the code, it will rebuild that layer)[cite\_start]. [cite: 323] [cite\_start]If using registry option: tag and push as v2 accordingly. [cite: 324] [cite\_start]If using local, ensure the image is built in local Docker. [cite: 325]
  * [cite\_start]**Update Kubernetes manifest:** Edit the `deployment.yaml` file to use the new image tag. [cite: 326] [cite\_start]Change `image: mywebapp:v1` to `image: mywebapp:v2`. [cite: 326] [cite\_start]Also, for clarity, you might update `imagePullPolicy` to `IfNotPresent` (should already be that). [cite: 327] [cite\_start]Save the file. [cite: 327]
  * [cite\_start]**Commit and push the change to Git:** [cite: 328]
    ```bash
    git add deployment.yaml
    git commit -m "Update image to v2"
    git push origin main
    ```
    [cite\_start][cite: 329]
    [cite\_start]Now the Git repository has the new desired state (image v2 for the deployment). [cite: 330]
  * [cite\_start]**Argo CD detects `OutOfSync`:** In the Argo CD UI, after a minute or so (or you can manually hit “Refresh” on the app), you should see the application status turn `OutOfSync` (yellow), and the UI will show that the Deployment is out of sync (the live state still has image v1, desired state says v2). [cite: 331] [cite\_start]This is Argo watching the git repo and noticing the change. [cite: 332]
  * [cite\_start]**Sync to deploy the update:** Click **Sync** again on the application. [cite: 333] [cite\_start]Argo CD will apply the new Deployment manifest. [cite: 334] [cite\_start]Kubernetes will perform a rolling update on the pod (terminate old pod, start new pod with image v2). [cite: 334] [cite\_start]Argo will wait until the new pod is up and reports healthy. [cite: 335] [cite\_start]Then the app status becomes `Synced` and `Healthy` again. [cite: 336]
  * [cite\_start]**Verify update:** Refresh the browser at `http://localhost:30007`. [cite: 337] [cite\_start]You should now see the v2 message (“Hello from Argo CD deployment v2\!”). [cite: 337] [cite\_start]This confirms the new version is running. [cite: 338] 🎉
  * [cite\_start]We have successfully done a GitOps style update: change in Git, Argo deploys it. [cite: 339] [cite\_start]Next, we’ll experiment with **rollbacks** – returning to a previous version if something goes wrong. [cite: 340]

### [cite\_start]Exercise 9: Rolling Back to a Previous Version [cite: 341]

  * [cite\_start]**Purpose:** Demonstrate how to quickly revert a bad deployment using Argo CD. [cite: 342] [cite\_start]We’ll roll back from v2 to v1 using Argo CD’s UI. [cite: 343]
  * [cite\_start]Assume the v2 deployment had an issue or we simply want to go back to v1: [cite: 344]
  * [cite\_start]**Using Argo CD UI History:** In the Argo CD application view for `mywebapp`, find the **History** or **History and Rollback** panel (usually a button or a tab in the app details). [cite: 345] [cite\_start]Here you should see a list of recent deployment syncs with their details (Git commit hashes or tags, and the date). [cite: 346] [cite\_start]You will see an entry for the v1 deployment (initial commit) and one for v2 (the latest commit). [cite: 347]
  * [cite\_start]**Initiate Rollback:** In the history list, locate the commit corresponding to the v1 state (it may show the commit message “Add initial K8s manifests...” or similar). [cite: 348] [cite\_start]There’s usually a **“Rollback”** button or three-dot menu next to it. [cite: 349] [cite\_start]Click rollback to that revision[16]. [cite: 349] [cite\_start]Confirm the action. [cite: 350]
  * [cite\_start]What this does: Argo CD will take the manifests from that previous Git commit (where image was v1) and re-apply them. [cite: 351] [cite\_start]Because our repo’s HEAD is still v2, Argo normally doesn’t permanently revert it in Git (it just syncs to the older commit). [cite: 352] [cite\_start]This is useful for emergencies: you can roll back without waiting for a Git revert. [cite: 353] [cite\_start]However, note that Argo will consider the app “temporarily” at an older revision. [cite: 354] [cite\_start]If auto-sync were on, we’d need to turn it off because auto-sync would try to sync back to v2 (head) immediately. [cite: 355] [cite\_start]Since we are in manual mode, it’s fine. [cite: 356]
  * [cite\_start]**Rollback deployment happens:** Argo CD will delete the v2 pod and spin up a new pod with image v1 (since that’s what the old manifest says). [cite: 357] [cite\_start]After a short time, the app should be back to running v1. [cite: 358] [cite\_start]Argo UI should show `Synced`/`Healthy` with the older commit. [cite: 359]
  * [cite\_start]**Verify in the app:** Refresh `http://localhost:30007` again. [cite: 360] [cite\_start]The message should be back to the v1 text (“Hello from Argo CD deployment\!” without the v2). [cite: 360]
  * [cite\_start]We successfully rolled back. [cite: 361] [cite\_start]In a real scenario, you might then fix whatever issue and re-deploy a v3, etc. [cite: 361]
  * [cite\_start]**Reset to HEAD:** Since our Git repo still has v2 as the latest, and we performed a UI rollback (which doesn’t automatically revert the git), Argo will show that we’re running a “non-head” revision. [cite: 362] [cite\_start]To get back to normal operation, you have a couple options: [cite: 363]
      * [cite\_start]Easiest: manually revert the commit in Git (make a new commit that sets image back to v1) and push it. [cite: 364] [cite\_start]Then Argo would consider that the new desired state and you’d be in sync (though effectively you just made v3 commit which equals v1 state). [cite: 365]
      * [cite\_start]Alternatively, after demonstration, just re-sync to HEAD (v2) if we want to continue with v2. [cite: 366]
  * [cite\_start]But for our learning, we’ll now proceed to demonstrate self-healing, which is easier if we have auto-sync on with a known good state. [cite: 367] [cite\_start]Let’s assume we rolled back because v2 was bad, so we’ll stay on v1 for now. [cite: 368]
  * [cite\_start](In summary, rollback via Argo CD is quick via UI. [cite: 369] [cite\_start]It highlights how Git history is leveraged for safe reversions[15]. [cite: 369] [cite\_start]However, remember to reconcile with your Git repo later – GitOps best practice is to actually commit the rollback or fix forward.) [cite: 369]

### [cite\_start]Exercise 10: Enabling Auto-Sync (Continuous Deployment) and Self-Healing [cite: 370]

  * [cite\_start]**Purpose:** Show how Argo CD can automatically keep apps in sync and fix drift without manual intervention. [cite: 371] [cite\_start]We will turn on auto-sync (with self-heal) for our application. [cite: 372]
  * [cite\_start]**Enable auto-sync in Argo CD:** In the Argo CD UI, navigate to the app `mywebapp` -\> Application settings (there’s an option to edit the application). [cite: 373] [cite\_start]Enable the **Auto-Sync** option. [cite: 374] [cite\_start]Also enable **Self-Heal** (this option appears when auto-sync is on, typically labeled “Automatically apply after sync if drift detected” or similar). [cite: 374] [cite\_start]Save the settings. [cite: 375]
  * [cite\_start]With these settings, Argo CD will **periodically check** the live state and if it finds it diverged from Git, it will automatically sync it back. [cite: 376] [cite\_start]Also, any new commits to Git will be deployed immediately. [cite: 377]
  * [cite\_start]**Test auto-sync (Git change):** Let’s do a quick test of auto-sync by deploying a change without clicking sync: [cite: 378]
      * [cite\_start]If you earlier rolled back to v1 via UI, the Git latest (v2) is still different. [cite: 379] [cite\_start]The app is `OutOfSync` now (since auto-sync is on, Argo might have already re-synced to v2 unless we locked it). [cite: 380]
      * [cite\_start]Assuming we are on v1 commit running, let’s actually do a new commit: edit `deployment.yaml` image to v2 again or some other change, commit and push. [cite: 381]
      * [cite\_start]Watch Argo CD. [cite: 382] [cite\_start]Within \~sync interval (usually 3 minutes or immediately if webhooks were set up), Argo CD will detect it and start a sync on its own. [cite: 382] [cite\_start]You’ll see it go to `Synced` without manual input. [cite: 383]
      * [cite\_start]This demonstrates continuous deployment: whenever code/config changes in Git, ArgoCD deploys it. [cite: 384]
  * [cite\_start]**Test self-heal (manual drift correction):** Now the fun part: simulate someone manually changing or deleting a resource in the cluster and watch Argo fix it. [cite: 385]
      * [cite\_start]For example, use `kubectl` to delete the app’s pod: [cite: 386]
        ```bash
        kubectl delete pod -l app=mywebapp -n default
        ```
        [cite\_start][cite: 387]
        [cite\_start]This simulates an accidental deletion of a running component. [cite: 388] [cite\_start]Kubernetes itself will try to reschedule because the Deployment says 1 replica (so it will actually restart a pod automatically even without Argo’s involvement, demonstrating Kubernetes self-healing). [cite: 389]
      * [cite\_start]To better see Argo’s role, perhaps try modifying something less auto-fixed by K8s: e.g. manually edit the Deployment’s replica count. [cite: 390] [cite\_start]Run: [cite: 391]
        ```bash
        kubectl scale deploy/mywebapp-deployment -n default --replicas=2
        ```
        [cite\_start][cite: 392]
        [cite\_start]This manually scales the deployment to 2 pods, which is a deviation from the desired state (Git and Argo think it should be 1 replica). [cite: 393]
      * [cite\_start]Within a short time, Argo CD should detect this drift (live has 2, desired is 1) and because self-heal is on, Argo will **automatically correct it**. [cite: 394] [cite\_start]It will scale the deployment back down to 1 (to match Git). [cite: 395] [cite\_start]In the Argo UI you might see an Operation triggered or the app going `OutOfSync` and then quickly back to `Synced`. [cite: 396]
      * [cite\_start]You can also try deleting the Service: [cite: 397]
        ```bash
        kubectl delete svc mywebapp-service -n default
        ```
        [cite\_start][cite: 398]
        [cite\_start]Argo CD will notice the Service is missing (exists in Git, gone in cluster) and will recreate it for you within the self-heal interval[12]. [cite: 399]
  * [cite\_start]These examples show Argo CD’s **self-healing** feature: it keeps the deployment fully aligned with the Git config, even recovering from manual errors or unintended changes automatically. [cite: 400] [cite\_start]This reduces configuration drift and ensures stability[7]. [cite: 401]
  * [cite\_start]**Observe Argo CD notifications:** In the UI, after these actions, look at the timeline or app events – Argo will log something like “Auto-sync triggered: cluster drift detected (Deployment replicas was 2, desired 1)” and it will apply the correction. [cite: 402] [cite\_start]The app returns to `Synced` state without human intervention. [cite: 403]
  * [cite\_start]We have now experienced how Argo CD can automatically manage our application’s state, including deploying updates and self-healing any drift. [cite: 404] [cite\_start]This is extremely powerful for day-to-day operations, as it means less manual babysitting of deployments and more trust that the running state matches the declared state. [cite: 405]

### [cite\_start]Exercise 11: Clean-up (Optional) [cite: 406]

  * [cite\_start]If time permits, you can show how to clean up everything: [cite: 407]
      * [cite\_start]Remove the application from Argo CD (which can also delete all the Kubernetes resources if you choose). [cite: 407]
      * [cite\_start]Uninstall Argo CD (by deleting the namespace or the resources). [cite: 408]
      * [cite\_start]Or simply leave everything as is for further experimentation. [cite: 409]
  * [cite\_start]For example: [cite: 410]
    ```bash
    argocd app delete mywebapp  # if using CLI, or do in UI
    kubectl delete ns argocd    # remove Argo CD components
    ```
    [cite\_start][cite: 411]
  * [cite\_start]And perhaps disable Kubernetes in Docker Desktop if not needed further. [cite: 412]
  * (Clean-up is optional; if this is a throwaway environment, it can be destroyed when Docker Desktop is closed.) [cite\_start][cite: 413]

## [cite\_start]Conclusion and Q\&A [cite: 414]

[cite\_start]In this team session, we covered a **basic introduction to Kubernetes** (clusters, pods, deployments, services) and **GitOps with Argo CD**. [cite: 415] [cite\_start]We learned how Argo CD fits into the Kubernetes landscape by using Git as the source of truth for deployments[9]. [cite: 416] [cite\_start]We saw how to install and configure Argo CD on a local cluster, and then practiced deploying a sample application through it. [cite: 417] [cite\_start]Key Argo CD daily operations – **syncing applications, monitoring health, rolling back, and auto-healing** – were demonstrated in a hands-on way. [cite: 418] [cite\_start]By using a local Kubernetes (Docker Desktop) and Argo CD, the team got to experience the full GitOps workflow: editing code and config in Git and having an automated system apply those changes to the cluster. [cite: 419] [cite\_start]We observed how Argo CD **continuously monitors** the environment and can correct drift to ensure the cluster matches the desired state from Git[20]. [cite: 420]

[cite\_start]**Key takeaways:** [cite: 421]

  * [cite\_start]**Kubernetes** provides a powerful platform for running containers, but managing YAML and deployments manually can be complex – this is where **GitOps** shines. [cite: 421]
  * [cite\_start]**Argo CD** allows us to manage Kubernetes apps declaratively with Git, offering benefits like clear audit trails, easy rollbacks via Git history, and less manual intervention for ops tasks[6]. [cite: 422]
  * [cite\_start]Day-to-day tasks like deploying a new version or reverting a bad release are simplified to Git operations (commit or revert) and Argo CD handles the rest, making continuous delivery safer and more reliable. [cite: 423]
  * [cite\_start]Enabling features like auto-sync and self-heal can further reduce toil by automatically reconciling state and preventing config drift or manual errors from causing lasting issues[12]. [cite: 424]

[cite\_start]Feel free to ask any questions or clarifications. [cite: 425] [cite\_start]We can also discuss how these concepts would apply in our real projects (e.g., how we might structure our Git repos for apps, how to handle multiple environments with Argo CD, etc.). [cite: 425]

## [cite\_start]References & Resources: [cite: 426]

  * [cite\_start]Kubernetes official docs – “What is Kubernetes”[1] [cite: 426]
  * [cite\_start]GitOps methodology and principles[4][7] [cite: 426]
  * [cite\_start]Argo CD official docs – Overview and features[24][14] [cite: 426]
  * [cite\_start]Argo CD rollbacks and self-healing explained[15][12] [cite: 426]

[1] [2] [3] What Is Kubernetes? | [cite\_start]New Relic [cite: 427]
[cite\_start][https://newrelic.com/blog/how-to-relic/what-is-kubernetes](https://newrelic.com/blog/how-to-relic/what-is-kubernetes) [cite: 428]

[cite\_start][4] [5] [6] [7] [8] GitOps powered by Argo projects [cite: 429]
[cite\_start][https://techtalks.qima.com/gitops-powered-by-argo-projects/](https://techtalks.qima.com/gitops-powered-by-argo-projects/) [cite: 430]

[cite\_start][9] [10] [13] [14] [24] Argo CD - Declarative GitOps CD for Kubernetes [cite: 431]
[cite\_start][https://argo-cd.readthedocs.io/en/stable/](https://argo-cd.readthedocs.io/en/stable/) [cite: 432]

[cite\_start][11] [12] [15] [16] [17] [18] [20] [21] Argo CD: A Ultimate Guide to Features and Configurations [cite: 433]
[cite\_start][https://devopscube.com/argo-cd-ultimate-guide/](https://devopscube.com/argo-cd-ultimate-guide/) [cite: 434]

[cite\_start][19] [22] [23] Getting Started - Argo CD - Declarative GitOps CD for Kubernetes [cite: 435]
[cite\_start][https://argo-cd.readthedocs.io/en/stable/getting\_started/](https://argo-cd.readthedocs.io/en/stable/getting_started/) [cite: 436]
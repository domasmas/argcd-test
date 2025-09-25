---
marp: true
theme: default
---

# 🥑 GitOps and Argo CD

An Introduction to Declarative, Continuous Delivery

---

# 🤔 What is GitOps?

GitOps is a modern way to do Continuous Delivery. It uses **Git** as the **single source of truth** for declarative infrastructure and applications.

- **Declarative:** You define the desired state of your entire system in Git.
- **Versioned & Auditable:** Every change to your system is a Git commit. You get a full audit trail for free.
- **Automated:** An automated agent ensures the live environment matches the state defined in Git.
- **Pull-based:** The agent _pulls_ the desired state from Git, rather than having changes _pushed_ to it.

---

# 🌊 The GitOps Workflow

1.  A developer pushes a code change to your application's Git repository.
2.  An automated CI (Continuous Integration) pipeline builds a new container image and pushes it to a registry.
3.  The CI pipeline then updates a configuration file (e.g., Kubernetes YAML) in a separate **environment Git repository**. This update changes the image tag to the newly built version.
4.  An agent (Argo CD) running in the Kubernetes cluster detects this change.
5.  The agent pulls the new configuration from the environment repo and applies it to the cluster.

---

# 🥑 What is Argo CD?

Argo CD is a **declarative, GitOps continuous delivery tool** for Kubernetes.

- It's a popular open-source project and part of the CNCF.
- It constantly monitors your running applications and compares their live state against the desired state defined in your Git repository.
- It makes it easy to see differences and synchronize the cluster to the desired state.

---

# 🏛️ Argo CD Architecture: The Components

Argo CD is composed of three main services that run inside your Kubernetes cluster:

1.  **API Server:** Exposes the API that the Web UI, CLI, and CI/CD systems use. It's responsible for authentication, authorization, and managing applications.

2.  **Repository Server:** An internal service that caches your Git repository locally and is responsible for generating the Kubernetes manifests from your source files (e.g., by using Kustomize or Helm).

3.  **Application Controller:** The core of Argo CD. This controller continuously monitors your running applications and compares the live state against the desired state (from the Git repo). It triggers the sync operations.

---

# 🔄 The Reconciliation Loop (Under the Hood)

The Application Controller is where the magic happens. It's in a constant loop:

1.  **Fetch from Git:** It tells the Repository Server to fetch the latest manifests from the target branch in your Git repository.
2.  **Observe Live State:** It connects to the Kubernetes API server to get the current, live state of all the resources (Deployments, Services, etc.) that make up your application.
3.  **Compare (Diff):** It performs a "diff" between the manifests from Git (desired state) and the resources in the cluster (live state).
4.  **Report Status:** If there's a difference, the application is marked as `OutOfSync`. If they match, it's `Synced`. This status is updated and visible in the UI and API.

This loop runs approximately every 3 minutes by default.

---

# 🚀 Argo CD in Practice

This is the user-facing workflow:

1.  You **define an `Application`** in Argo CD, telling it where your Git repo is and which cluster to deploy to.
2.  Argo CD automatically performs the first **comparison**.
3.  It reports the application as `OutOfSync` because nothing has been deployed yet.
4.  You can then **Sync** the application. You can do this manually via the UI/CLI or configure it to happen automatically.
5.  When you sync, the Application Controller applies the manifests from Git to the cluster.

---

# 🖥️ The Argo CD UI

Argo CD provides a powerful web interface to visualize your applications and their status.

![Argo CD UI](https://argo-cd.readthedocs.io/en/stable/assets/application-ui.png)

- **Visualize:** See the health and status of every component of your application.
- **Diff:** See exactly what's different between Git and the live cluster.
- **Sync & Rollback:** Trigger a synchronization or roll back to a previous version with the click of a button.

---

# ✅ Summary

- **GitOps** uses Git as the single source of truth for your infrastructure and applications.
- **Argo CD** is a tool that implements the GitOps pattern for Kubernetes.
- It works via a **reconciliation loop** that constantly compares the desired state in Git with the live state in the cluster.
- This approach makes your deployments more **reliable, auditable, and automated**.

---

# 🙏 Questions?

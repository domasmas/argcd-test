# Proposed 3-Hour Agenda

1. **Introduction & Overview (10 min):** Objectives of the session and what the team will learn.
2. **Kubernetes Basics (20 min):** Brief introduction to Kubernetes (clusters, pods, services, etc.) – just enough to contextualize the hands-on.
3. **GitOps and Argo CD Introduction (20 min):** Explain GitOps principles and how Argo CD leverages GitOps for Kubernetes deployments.
4. **Kubernetes Manifest Tools: Helm Charts and Kustomize (15 min):** Overview of Helm Charts for templating and packaging, and Kustomize for customization of Kubernetes manifests.
5. **How Argo CD Works & Key Features (25 min):** Explain Argo CD workflow, syncing mechanism, rollbacks, health checks, self-healing, and integration with tools like Kustomize and Argo Rollouts with examples.
6. **_(Optional break – 10 min)_**
7. **Hands-On Setup (15 min):** Enable local K8s in Docker Desktop, install Argo CD on cluster, and prepare the environment for exercises.
8. **Hands-On Exercises (~75 min total):** Team members take turns to perform:
   - Creating a sample .NET web app and containerizing it.
   - Writing Kubernetes manifests (using Kustomize for customization) for the app and pushing to a Git repository.
   - Creating an Argo CD Application to deploy the app.
   - Demonstrating app sync, update (new version), rollback, and Argo CD’s self-healing (auto-sync).
   - (Each exercise is detailed in the “Hands-On Exercises” section below with step-by-step instructions.)
9. **Wrap-up and Q&A (10 min):** Recap key takeaways, answer questions.

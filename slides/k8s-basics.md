---
marp: true
theme: default
---

# ☸️ Kubernetes Basics

A High-Level Introduction to Container Orchestration

**⏱️ Duration:** 20 minutes

<!--
**(Start with a brief intro)**

"Good morning/afternoon, everyone. My name is [Your Name], and today we're going to take a high-level tour of Kubernetes. My goal is for you to leave this session understanding what Kubernetes is, the core problems it solves, and the fundamental building blocks it uses to do so."

"Don't worry if you're completely new to this; we'll start from the very beginning. By the end, you'll understand the 'why' behind its popularity and be familiar with terms like Pods, Deployments, and Services."
-->

---

# 🤔 What is Kubernetes?

It's a system that **automates** running applications in containers.

- **Manages** deployment, scaling, and failures automatically.
- **Orchestrates** containers across a group of machines.
- Originally from Google, now the industry standard.
- Often called **K8s**.

<!--
"So, what exactly *is* Kubernetes? At its heart, it's a powerful tool for managing containers. How many of you are familiar with Docker or other container technologies?"

**(Pause for a show of hands)**

"Great. So you know that containers package an application and its dependencies into a single, isolated unit. That's fantastic for one or two containers. But what happens when you need to run hundreds, or even thousands, of them in production? How do you update them without downtime? What happens if one crashes in the middle of the night?"

"This is the problem Kubernetes solves. It's an **orchestrator**. It manages the entire lifecycle of your containers automatically."

"It was born at Google, where they've been running containers at a massive scale for years. They open-sourced it, and now it's the de facto industry standard for running applications in the cloud."
-->

---

# 💡 The Core Philosophy: Immutable Infrastructure

A key mindset for understanding Kubernetes.

| Traditional (Mutable)                 | Modern (Immutable)                  |
| :------------------------------------ | :---------------------------------- |
| Servers are unique & manually managed | Instances are identical & automated |
| If one fails, you repair it           | If one fails, you replace it        |
| Leads to configuration drift          | Ensures consistency and reliability |

**Kubernetes is designed for an immutable approach.**

<!--
"The most important concept to grasp is the idea of 'Immutable Infrastructure'. In the old days, we treated our servers as mutable things. We'd log in, apply patches, change configs, and over time, each server became unique and difficult to reproduce. If one failed, we'd spend hours trying to repair it."

"In the world of Kubernetes, we treat our infrastructure as immutable, or unchangeable. Instances are identical and automated. If one has a problem or needs an update, you don't try to fix it; you simply replace it with a new, healthy one created from a versioned template. This mindset is key to building resilient, consistent, and self-healing systems."
-->

---

# 🏗️ Core Architecture: The Cluster

A Kubernetes cluster is a set of machines, called **nodes**, that run your applications. It consists of two main parts:

- **Control Plane:** The brain 🧠. It manages the cluster and makes decisions.
- **Nodes:** The workers 💪. They are machines (VMs or physical) that run your application containers.

---

# 🏗️ Cluster Diagram

The Control Plane manages the Nodes to run your applications.

```
+---------------------------------+
|         CONTROL PLANE           |
|  (The Brain: API, Scheduler)    |
+---------------------------------+
              |
              | Manages
              |
+-------------+-------------------+
|             |                   |
|   NODE 1    |   NODE 2          |   NODE ...
| (Worker)    | (Worker)          |  (Worker)
| - Pod       | - Pod             |  - Pod
| - Pod       | - Pod             |
+-------------+-------------------+
```

<!--
"To make all this magic happen, Kubernetes uses a cluster architecture. You can think of it as a master-worker setup."

"The **Control Plane** is the brain. It's the set of components that manages the entire cluster. You, the user, interact with the control plane, usually through its API. You tell it what you want your application to look like, and the control plane works to make it a reality. You don't interact with the individual worker nodes directly."

"The **Nodes** are the brawn. They are the worker machines that do the heavy lifting. Their job is to run your applications. Each node has a small agent called a `kubelet` that communicates with the control plane, receiving instructions and reporting back on the health of the applications it's running."

"So, in summary: We tell the *brain* (Control Plane) what to do, and the brain tells the *muscles* (Nodes) how to do it."
-->

---

# 📦 Pods: The Smallest Unit

A **Pod** is the smallest deployable object in Kubernetes.

- It's a wrapper around one or more containers.
- Containers in a Pod share the same network (IP address) and storage.
- **Pods are ephemeral (disposable).** They can be destroyed and replaced at any time.

---

# 📦 Pod Diagram

A Pod can contain one or more containers that work together.

```
+---------------------------+
|          POD              |
|   (Single IP Address)     |
|                           |
| +----------+ +----------+ |
| | Your App | |  Logging | |
| | Container| | Sidecar  | |
| +----------+ +----------+ |
|                           |
+---------------------------+
```

<!--
"Now let's drill down into how we run our applications. You might expect the basic unit to be a container, but in Kubernetes, it's actually a **Pod**."

"A Pod is a logical wrapper. Most of the time, a pod will contain just one main container—for example, your web server. However, it *can* hold multiple containers. This is useful when you have a helper process that needs to be tightly coupled with your main application. A common example is a 'sidecar' container for logging or monitoring that sits right next to your app."

"The key things to remember about Pods are that all containers inside one share the same network space—they can talk to each other on `localhost`—and they share storage volumes. They are a single, atomic unit. You can't run just one container from a two-container pod."

"And most importantly, **Pods are ephemeral**, or disposable. This ties back to the 'cattle, not pets' idea. You should never rely on a Pod sticking around. Kubernetes can and will destroy and recreate pods to handle failures or updates. This means you can't rely on its IP address, which brings us to our next topics."
-->

---

# 📜 The Declarative Model

In Kubernetes, you don't give commands. You **declare a desired state**.

**You tell Kubernetes _WHAT_ you want, not _HOW_ to do it.**

- **You write:** "I want 3 copies of my app running."
- **Kubernetes works to:** Make reality match your declaration.

This is the foundation of "self-healing" infrastructure.

---

# 🚀 Managing Pods: Deployments

You rarely create Pods directly. You use a **Deployment** to declare your desired state for them.

- A **Deployment** manages a set of identical Pods.
- **It ensures your desired state is met:**
  - If a Pod crashes, it creates a new one.
  - If a Node fails, it moves the Pods to a healthy Node.
- It handles **rolling updates** and **rollbacks** with zero downtime.

<!--
"Since Pods are ephemeral, we need a way to manage them. This is where **Deployments** come in, and it's where the declarative model shines."

"A Deployment is where you describe the desired state of your application. You write a configuration file, usually in YAML, that says, 'Hey Kubernetes, I want to run this container image, and I always want three copies, or replicas, of it running.' The Deployment controller then takes over. It's a continuous loop that checks: 'Does the current state match the desired state?' If you have only two running pods, it will create a third. If a node goes down and one pod disappears, the controller will immediately create a replacement on another healthy node."

"This is also how we perform updates. You just change the container image version in your Deployment file. Kubernetes will then perform a rolling update, carefully creating new pods and terminating old ones one by one, ensuring your application remains available throughout the process. And if something goes wrong, you can just as easily tell it to roll back to the previous version."
-->

---

# 🌐 Exposing Pods: Services

A **Service** gives you a stable network endpoint for your unstable Pods.

- **Problem:** Pods are replaced often, so their IP addresses change. How can other apps find them?
- **Solution:** A **Service** provides a single, stable IP address and DNS name. It acts as a load balancer, sending traffic to the healthy Pods.

---

# 🌐 Deployment + Service Diagram

A Service directs traffic to the Pods managed by a Deployment.

```
                      +-----------+
                      |           |
Incoming Traffic ---> |  SERVICE  | ---> [Pod 1 (IP: 10.1.1.2)]
                      |(Stable IP)|
                      |           | ---> [Pod 2 (IP: 10.1.1.3)]
                      +-----------+
                        |
                        '---> [Pod 3 (IP: 10.1.1.4)]
```

The Service finds all Pods with a specific label (e.g., `app=my-api`).

<!--
"Okay, so we have a Deployment that keeps a set of identical Pods running. But we have a problem. We just established that Pods can be destroyed and recreated at any time, and when they come back, they get a new IP address."

"So how does our frontend application talk to our backend application if the backend's IP address is always changing? How do external users access our website?"

"The answer is a **Service**. A Service is another Kubernetes object that provides a stable network abstraction on top of a group of Pods. You create a Service, and Kubernetes gives it a single, unchanging IP address and DNS name *within the cluster*."

"The Service continuously watches for Pods that match a certain label—for example, all pods with the label 'app: my-backend'. When traffic comes to the Service's stable IP, it automatically load-balances that traffic across all the healthy, matching pods."

"Think of it like a business's main phone number. The employees (the Pods) might change, but customers always call the same main number (the Service), and the receptionist directs the call to an available employee. This decouples our applications and makes our architecture robust and scalable."
-->

---

# 🤔 Why Use Kubernetes?

| Benefit          | How Kubernetes Achieves It                                      |
| :--------------- | :-------------------------------------------------------------- |
| **Self-Healing** | Automatically restarts or replaces failed containers.           |
| **Scalability**  | Scale apps up or down easily, or even automatically.            |
| **Portability**  | Runs the same way on any cloud (AWS, GCP, Azure) or on-premise. |
| **Efficiency**   | Packs containers smartly to maximize server resource usage.     |
| **Ecosystem**    | Huge community and thousands of tools built to work with it.    |

<!--
"So, let's tie it all together. Why go through the trouble of learning all these new concepts? What are the real-world benefits?"

"First, **Self-Healing**. As we saw with Deployments, Kubernetes automates recovery. No more manual intervention when a process crashes."

"Second, **Scalability**. Need to handle a traffic spike? You can change the replica count in your Deployment from 3 to 30 with one command. There's also a component called the Horizontal Pod Autoscaler that can do this automatically based on CPU or memory usage."

"Third, **Portability**. This is a huge one. Because you define your application in standard Kubernetes YAML files, you can run that same application on Google Cloud, on Amazon AWS, on Microsoft Azure, or even on your own servers in your data center, with minimal changes. It frees you from vendor lock-in."

"Fourth, **Efficiency**. Kubernetes is very smart about scheduling your pods across the available nodes to make the most of your CPU and Memory, which can save a lot of money on infrastructure costs."

"Finally, the **Ecosystem**. Kubernetes itself is just the core, but it's surrounded by a massive ecosystem of open-source tools for monitoring, logging, package management, security, and more, making it an incredibly powerful and extensible platform."
-->

---

# ✅ Summary: The Core Flow

1. You have a **Cluster** of **Nodes**.
2. You create a **Deployment** to declare your desired state.
   - _"I want 3 copies of my app container."_
3. The Deployment creates and manages **Pods** for you.
4. You create a **Service** to give your Pods a stable IP address.

This declarative workflow is the foundation of modern, resilient applications.

<!--
"Before we go to questions, let's quickly recap the entire flow."

"It all starts with a **Cluster**, which is our pool of computing resources made up of Nodes."

"We, the developers, define our application in a YAML file. In that file, we create a **Deployment** to describe our desired state—what container to run and how many replicas we want."

"The Deployment's job is to create and manage our **Pods**, ensuring the right number are always healthy and running on the cluster's **Nodes**."

"Finally, because Pods are unreliable as network endpoints, we create a **Service** to give them a stable IP address and load balance traffic between them."

"This simple but powerful pattern—Cluster, Deployment, Pod, Service—is the absolute core of working with Kubernetes."
-->

---

# 🙏 Questions?

**Next Up:** GitOps and Argo CD Introduction

<!--
Speaker notes for questions slide if needed.
-->

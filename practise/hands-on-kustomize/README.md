# Kustomize Hands-On: Understanding Base vs. Overlays

This exercise demonstrates the core power of Kustomize: customizing a single base configuration for multiple environments without duplicating YAML.

**Goal:** See how a `dev` overlay can change the replica count and add labels to a `base` deployment.

**Prerequisite:** `kubectl` v1.14+ (Kustomize is built-in).

---

### Step 1: The `base` Configuration

The `base` directory contains the standard, shared configuration for our application.

**(A) Explore the `base` files:**

- `base/deployment.yaml`: A simple NGINX deployment with `replicas: 1`.
- `base/kustomization.yaml`: Tells Kustomize that `deployment.yaml` is part of the base.

**(B) See the `base` output:**
Run this command to see what the standard YAML looks like:

```sh
kubectl kustomize base/
```

**Result:** You'll see the raw `deployment.yaml` content. Notice `replicas: 1`.

---

### Step 2: The `dev` Overlay

The `overlays/dev` directory contains our environment-specific customizations. It doesn't copy the base; it just describes the _changes_ we want to make.

**(A) Explore the `dev` overlay files:**

- `overlays/dev/patch.yaml`: A small snippet that says "I want `replicas: 2`".
- `overlys/dev/kustomization.yaml`: The magic file! It tells Kustomize to:
  1. Use the `base` configuration as a starting point.
  2. Apply the `patch.yaml` to change the replica count.
  3. Add a common label `env: dev` to everything.

---

### Step 3: See the Result!

Now, let's build the `dev` overlay to see Kustomize merge the `base` and the `overlay`.

**(A) Build the `dev` overlay:**

```sh
kubectl kustomize overlays/dev/
```

**(B) Check the final YAML:**
You will see a new, combined Deployment manifest. Look for these changes:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    env: dev # <-- The new label was added!
  name: my-app
spec:
  replicas: 2 # <-- The replica count was changed!
  selector:
    matchLabels:
      app: my-app
      env: dev # <-- The label was added here too!
  template:
    metadata:
      labels:
        app: my-app
        env: dev # <-- And here!
# ...
```

---

## Core Concepts You've Learned

- **DRY (Don't Repeat Yourself):** We customized a deployment without copying any YAML.
- **Bases and Overlays:** The fundamental pattern for managing environments.
- **Patches:** How to make small, targeted changes to a base configuration.
- **Declarative Customization:** You declare _what_ you want to change in `kustomization.yaml`, not _how_ to change it.

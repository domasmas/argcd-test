# Hands-On Kustomize (Super Simple Edition)

A tiny lab that shows how one base file can be transformed into multiple environment-specific variants with just a few, easy-to-read overlays.

## What You Need

- `kubectl` v1.14 or newer (includes Kustomize by default)
- No cluster required unless you want to `kubectl apply` the output

---

## Folder Layout

```
hands-on-kustomize/
├── base/
│   ├── config.yaml          # Plain ConfigMap (the "recipe")
│   └── kustomization.yaml   # Points to the recipe
└── overlays/
    ├── dev/                 # Dev tweaks
    ├── prod/                # Production tweaks
    └── test/                # Test tweaks + extra config
```

The goal: run `kubectl kustomize` on each directory and compare the small differences.

---

## Step 1 – Inspect the Base

```powershell
kubectl kustomize base/
```

Expected values:

- name: `my-config`
- data:
  - `greeting: Hello`
  - `count: "1"`
  - `environment: base`

Everything else in the overlays starts from this.

---

## Step 2 – Dev Overlay (add a little spice)

```powershell
kubectl kustomize overlays/dev/
```

What changed?

- Name becomes `dev-my-config` (thanks to `namePrefix`)
- Labels added: `env=dev`, `team=developers`
- Data overridden by the patch:
  - `greeting: Hello Dev World`
  - `count: "3"`
  - `environment: development`
  - `debug: "true"`

**Takeaway:** patches + labels + prefixes = environment-specific config without copy/paste.

---

## Step 3 – Prod Overlay (tighten things up)

```powershell
kubectl kustomize overlays/prod/
```

Differences vs. base:

- Name: `prod-my-config-live` (prefix + suffix)
- Labels: `env=prod`, `team=operations`
- Data:
  - `greeting: Welcome to Production`
  - `count: "10"`
  - `environment: production`
  - `debug: "false"`
  - `monitoring: enabled`

**Takeaway:** Overlay can both remove and add keys, not just tweak existing ones.

---

## Step 4 – Test Overlay (add an extra resource)

```powershell
kubectl kustomize overlays/test/
```

Two resources are produced:

1. Updated `my-config` with:
   - `greeting: Test Environment Ready`
   - `environment: testing`
   - `testMode: "true"`
2. A brand new ConfigMap named `test-extra-config` (declared in `resources`)

**Takeaway:** Overlays can bring their own files and still inherit the base.

---

## Quick Reference: Kustomize Features in Play

| Feature        | Where used    | Why it helps                            |
| -------------- | ------------- | --------------------------------------- |
| `resources`    | all dirs      | points to base and any extra files      |
| `commonLabels` | overlays      | ensures every object carries env labels |
| `namePrefix`   | dev/prod      | avoids collisions between environments  |
| `nameSuffix`   | prod          | further disambiguates resource names    |
| `patches`      | dev/prod/test | override only the fields you need       |

---

## Try It Yourself

1. **Add a staging overlay**

   - Copy `overlays/dev` to `overlays/staging`
   - Change the labels to `env: staging`
   - Tweak data (e.g., `count: "2"`)
   - Run `kubectl kustomize overlays/staging/`

2. **Change the base**
   - Add `version: "1.0"` to `base/config.yaml`
   - Re-run each overlay command; the new key flows automatically.

---

## Where This Fits in GitOps

- Git stays the source of truth.
- Argo CD (or any GitOps controller) detects `kustomization.yaml` automatically.
- Each overlay can become an Argo CD application pointing at its own path.
- Change the base? Every environment gets the update the next time it syncs.

Enjoy experimenting—this setup is intentionally tiny so you can focus on the Kustomize mechanics without getting lost in YAML noise.

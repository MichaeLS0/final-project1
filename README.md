# Final Project: CI/CD from GitHub → Docker Hub → Kubernetes

A minimal, **working** Flask app with a GitHub Actions pipeline that:
1) Builds a Docker image
2) Pushes it to Docker Hub
3) Deploys/updates it on Kubernetes using `kubectl`

## Repo Structure
```
.
├─ app/
│  ├─ main.py
│  └─ requirements.txt
├─ k8s/
│  ├─ deployment.yaml
│  └─ service.yaml
├─ Dockerfile
└─ .github/workflows/cicd.yml
```

## Prerequisites
- A Kubernetes cluster you can reach from GitHub Actions (e.g., K3s, EKS, GKE, etc.).
- A working `kubeconfig` for that cluster.
- A Docker Hub account and repository (will be created on first push).

## Required GitHub Secrets
Set these in your GitHub repo → Settings → Secrets and variables → **Actions** → **New repository secret**:

- `DOCKERHUB_USERNAME` → your Docker Hub username (e.g., `michaels0`)
- `DOCKERHUB_TOKEN` → a Docker Hub **access token** (NOT your password). Create at: Docker Hub → Account Settings → Security.
- `KUBECONFIG_B64` → **base64-encoded** contents of your kubeconfig. Example to generate:
  ```bash
  # Linux/macOS
  base64 -w0 ~/.kube/config > kubeconfig.b64
  # If -w is unsupported (macOS), use:
  base64 ~/.kube/config | tr -d '\n' > kubeconfig.b64
  # Then copy the file's single-line content into the secret
  ```

## How it works
- On push to `main`, the workflow builds the image and pushes:
  - `${DOCKERHUB_USERNAME}/final-flask:sha-<gitsha>`
  - `${DOCKERHUB_USERNAME}/final-flask:latest`
- It writes the kubeconfig from `KUBECONFIG_B64`, applies manifests, and then **sets the deployment image** to the newly built tag to force a rollout.

## Kubernetes
- `k8s/deployment.yaml` defines a 1‑replica deployment exposing container port 5000.
- `k8s/service.yaml` is a `LoadBalancer` service mapping port 80 → 5000.
  - If your cluster doesn't support LoadBalancer, change `type: LoadBalancer` to `NodePort`.

## Local test (optional)
```bash
docker build -t final-flask:local .
docker run -p 5000:5000 final-flask:local
curl http://localhost:5000/
# -> Hello, Kubernetes!
```

## Notes
- You can rename the image by editing `IMAGE_REPO` in the workflow.
- The workflow installs `kubectl` v1.30.0 (adjust if needed).
- Namespace defaults to `default`. Change `K8S_NAMESPACE` if you want.
```

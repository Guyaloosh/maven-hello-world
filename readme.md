# Maven Hello World - DevOps Pipeline

A complete CI/CD pipeline demonstrating DevOps best practices with Java, Maven, Docker, Helm, and ArgoCD.

## Architecture Overview

```
┌──────────────┐     ┌─────────────────┐     ┌────────────┐     ┌──────────────┐
│   GitHub     │────▶│ GitHub Actions  │────▶│ Docker Hub │────▶│  Kubernetes  │
│  (Source)    │     │   (CI/CD)       │     │  (Registry)│     │  (ArgoCD)    │
└──────────────┘     └─────────────────┘     └────────────┘     └──────────────┘
```

## Project Structure

```
maven-hello-world/
├── .github/workflows/
│   └── ci-cd.yml           # GitHub Actions pipeline
├── argocd/
│   └── application.yaml    # ArgoCD application manifest
├── helm/myapp/
│   ├── Chart.yaml          # Helm chart metadata
│   ├── values.yaml         # Default configuration
│   └── templates/          # Kubernetes manifests
├── myapp/
│   ├── pom.xml             # Maven configuration
│   └── src/                # Java source code
└── Dockerfile              # Container image definition
```

## Pipeline Jobs

| Job | Description |
|-----|-------------|
| Build Validation | Compile code, bump version |
| Tests | Run unit tests |
| Docker Build | Build and push image to Docker Hub |
| Helm Validation | Lint and validate Helm chart |
| Release | Create GitHub Release with notes |

## Setup

### Prerequisites

- Java 11+
- Maven 3.x
- Docker
- Kubernetes cluster (Minikube)
- ArgoCD installed on cluster

### 1. Clone and Configure

```bash
git clone https://github.com/Guyaloosh/maven-hello-world.git
cd maven-hello-world
```

### 2. GitHub Secrets

Add these secrets in GitHub → Settings → Secrets → Actions:

| Secret | Value |
|--------|-------|
| `DOCKER_USERNAME` | Your Docker Hub username |
| `DOCKER_PASSWORD` | Docker Hub access token |

### 3. Local Build

```bash
cd myapp
mvn clean package
java -jar target/myapp-*.jar
```

### 4. Docker Build (Local)

```bash
docker build -t guyaloosh/maven-hello-world:latest .
docker push guyaloosh/maven-hello-world:latest
```

### 5. Deploy with ArgoCD

```bash
# Create namespace
kubectl create namespace myapp

# Apply ArgoCD application
kubectl apply -f argocd/application.yaml

# Check status
kubectl get application myapp -n argocd
kubectl get pods -n myapp
```

### 6. View Application Logs

```bash
kubectl logs -n myapp -l app.kubernetes.io/name=myapp
```

## CI/CD Workflow

### Trigger
- Push to `main` branch
- Pull request to `main`

### Pipeline Flow

```
build-validation ──▶ tests ──┬──▶ docker-build ──┬──▶ release
                             └──▶ helm-validation─┘
```

### Version Bumping

The pipeline automatically increments the patch version:
```
1.0.0 → 1.0.1 → 1.0.2 → ...
```

## ArgoCD Sync

ArgoCD is configured with:
- **Automated sync** - deploys changes automatically
- **Self-heal** - reverts manual cluster changes
- **Prune** - removes deleted resources

### Manual Sync

```bash
# Via UI
# Open https://localhost:8080 and click SYNC

# Via CLI
kubectl delete job myapp -n myapp
kubectl -n argocd patch application myapp --type merge -p '{"metadata":{"annotations":{"argocd.argoproj.io/refresh":"hard"}}}'
```

## Useful Commands

### Git

```bash
# Create feature branch
git checkout -b feature/my-feature

# Push and create PR
git push -u origin feature/my-feature

# Merge to main
git checkout main
git merge feature/my-feature
git push origin main
```

### Kubernetes

```bash
# View pods
kubectl get pods -n myapp

# View logs
kubectl logs <pod-name> -n myapp

# Delete and resync
kubectl delete job myapp -n myapp
```

### ArgoCD

```bash
# Port forward UI
kubectl port-forward svc/argocd-server -n argocd 8080:443

# Get admin password
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d

# Check app status
kubectl get application myapp -n argocd
```

### Docker

```bash
# Build
docker build -t guyaloosh/maven-hello-world:latest .

# Push
docker push guyaloosh/maven-hello-world:latest

# Run locally
docker run guyaloosh/maven-hello-world:latest
```

## Security

- Container runs as non-root user (UID 1001)
- Read-only root filesystem
- Minimal base image
- No privilege escalation

## Author

Guy Aloosh

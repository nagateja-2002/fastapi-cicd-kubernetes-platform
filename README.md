# FastAPI CI/CD Kubernetes Platform

A small FastAPI application packaged with Docker and deployed to a local Kubernetes cluster using Kind. The project demonstrates application testing, an automated GitHub Actions test-and-build workflow, Kubernetes health probes, and basic rollout validation.

> **Scope:** This is a local learning project. The GitHub Actions workflow tests the code and builds an image; it does not publish the image or automatically deploy to a remote cluster.

## Features

- FastAPI application with root, health, and Prometheus-format metrics endpoints
- Docker image based on `python:3.12-slim`
- Four application tests documented as passing in the local validation record
- GitHub Actions workflow for dependency installation, tests, and Docker image build
- Kubernetes Deployment with two replicas, a ClusterIP Service, and health probes
- Windows command scripts with a guard that requires the `kind-sre-lab` Kubernetes context
- Deployment troubleshooting, validation notes, and rollback instructions

## Architecture

```text
Code change / pull request
          |
          v
GitHub Actions
  - install Python dependencies
  - run pytest
  - build Docker image (no push)
          
Local developer workflow
          |
          v
Docker image -> Kind cluster -> Kubernetes Service -> 2 FastAPI Pods
                                      |
                                      +-> /health readiness/liveness probes
```

The GitHub Actions workflow is CI only. The Kind deployment is a separate local workflow run by the developer.

## Repository layout

| Path | Purpose |
|---|---|
| `app/main.py` | FastAPI endpoints |
| `app/tests/` | Application tests |
| `Dockerfile` | Container image definition |
| `k8s/deployment.yaml` | Two-replica Deployment and probes |
| `k8s/service.yaml` | ClusterIP Service |
| `.github/workflows/ci.yml` | Hosted test-and-build workflow |
| `scripts/deploy.cmd` | Builds image, loads it into Kind, applies manifests, and waits for rollout |
| `scripts/health-check.cmd` | Checks rollout and starts a local port-forward |
| `scripts/rollback.cmd` | Rolls back the local Deployment after checking the context |
| `docs/architecture.md` | Resource and request-flow overview |
| `docs/troubleshooting.md` | Common problems and investigation tips |
| `docs/validation-evidence.md` | Recorded results and CI caveat |

## Prerequisites

- Docker Desktop or Docker Engine running
- Python 3.12 recommended for matching the CI image
- Kind and kubectl
- A local Kind cluster named `sre-lab`, which normally uses the context `kind-sre-lab`

## Run tests locally

From the repository root, create and activate a virtual environment, then install dependencies:

```powershell
py -3.12 -m venv .venv
.\.venv\Scripts\Activate.ps1
python -m pip install -r app/requirements.txt
python -m pytest app/tests -v
```

You can also use an existing Python environment with the dependencies installed.

## Build the Docker image

From the repository root:

```bash
docker build -t fastapi-cicd-platform:1.0.0 .
```

## Deploy to the local Kind cluster (Windows)

The deployment script checks that the active context is exactly `kind-sre-lab` and stops if it is not.

```powershell
kubectl config current-context
scripts\deploy.cmd
```

Review the context before running the script. It builds the image, loads it into the Kind cluster named `sre-lab`, creates the `fastapi-platform` namespace if needed, applies `k8s/`, and waits for the Deployment rollout.

Check workload status:

```bash
kubectl get deployments,pods,services -n fastapi-platform
kubectl rollout status deployment/fastapi-platform -n fastapi-platform
kubectl get events -n fastapi-platform --sort-by=.metadata.creationTimestamp
```

## Check the application

Run the port-forward helper in a terminal:

```powershell
scripts\health-check.cmd
```

It starts a port-forward from local port `18000` to the Service port. Keep that terminal running. In another terminal, test:

```powershell
curl.exe http://localhost:18000/
curl.exe http://localhost:18000/health
curl.exe http://localhost:18000/metrics
```

Expected endpoint behavior is described below. Confirm the actual responses in your environment.

| Endpoint | Purpose |
|---|---|
| `/` | Application information |
| `/health` | Health status used by Kubernetes probes |
| `/metrics` | Application metrics in Prometheus exposition format |

## GitHub Actions

The workflow at `.github/workflows/ci.yml` runs on pushes and pull requests targeting `main`, plus manual dispatch. Its steps install dependencies, run pytest, and build a Docker image with `push: false`.

Check the [Actions tab](https://github.com/nagateja-2002/fastapi-cicd-kubernetes-platform/actions) for the latest hosted run. The repository documentation records local test and Kind deployment results, but a successful hosted GitHub Actions run has not been confirmed in the validation evidence yet.

## Rollback

The rollback helper also checks the active context before changing the local Deployment:

```powershell
scripts\rollback.cmd
```

Then verify the Deployment rollout and available replicas:

```bash
kubectl rollout status deployment/fastapi-platform -n fastapi-platform
kubectl get deployments,pods -n fastapi-platform
```

## Validation record

The existing validation notes report that four application tests passed locally, the local Kind Deployment reached two available replicas, and the `/health` and `/metrics` endpoints returned HTTP 200. These are prior recorded results, not tests executed by this README update.

See [validation evidence](docs/validation-evidence.md) for scope and the hosted-CI status.

## Limitations and next steps

- No Prometheus server or Grafana dashboard is provisioned by this repository.
- GitHub Actions does not publish the image or perform a cluster deployment.
- The Kubernetes cluster and image loading are local Kind resources.
- A future extension could add image publishing, a secure deployment workflow, and cluster metrics collection with appropriate secrets, permissions, and environment controls.

## Safety

- Verify the Kubernetes context before applying, rolling back, or deleting resources.
- Do not point the provided scripts at production or company clusters.
- Never commit cloud credentials, Kubernetes credentials, tokens, or confidential environment details.

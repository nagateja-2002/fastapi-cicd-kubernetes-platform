# Architecture

## Request flow

Client -> Kubernetes ClusterIP Service -> FastAPI Pods

The Deployment maintains two application replicas.

## Application endpoints

- `/` - Application information
- `/health` - Application health status
- `/metrics` - Application metrics in Prometheus format

## Kubernetes resources

- Namespace: `fastapi-platform`
- Deployment: `fastapi-platform`
- Replicas: 2
- Service: `fastapi-platform`
- Service port: 80
- Container port: 8000

Readiness and liveness probes use `/health`.

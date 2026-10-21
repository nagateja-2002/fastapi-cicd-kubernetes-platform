# Validation Evidence

## Application tests

Four application tests passed locally:

- Root endpoint metadata
- Health endpoint
- Incident mode change and reset
- Prometheus metrics endpoint

## Kubernetes validation

The local Kind Deployment reached 2/2 available replicas and completed its rollout successfully.

## Endpoint checks

- `/health` returned HTTP 200 with status UP.
- `/metrics` returned HTTP 200 and exposed application metrics.

## CI status

The GitHub Actions workflow is configured to run tests and build the Docker image.
A successful hosted GitHub Actions run has not yet been verified.

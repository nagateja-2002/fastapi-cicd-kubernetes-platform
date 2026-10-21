# Troubleshooting

## Port-forward reports that the port is already in use

Another process may already be forwarding port 18000.
Check whether the endpoint works before starting another port-forward:

    curl.exe -i http://127.0.0.1:18000/health

If it returns HTTP 200, use the existing port-forward.

## Pods are not ready

First, verify the Kubernetes context:

    kubectl config current-context

Expected context: kind-sre-lab

Inspect resources and events:

    kubectl get deployment,pods,service -n fastapi-platform
    kubectl describe deployment fastapi-platform -n fastapi-platform
    kubectl get events -n fastapi-platform --sort-by=.metadata.creationTimestamp

## Application logs

    kubectl logs deployment/fastapi-platform -n fastapi-platform

Only troubleshoot the local lab. Do not apply changes to a production cluster.

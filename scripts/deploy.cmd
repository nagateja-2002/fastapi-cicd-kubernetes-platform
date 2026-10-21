@echo off
setlocal

cd /d "%~dp0.."

echo Checking Kubernetes context...
for /f "delims=" %%C in ('kubectl config current-context') do set "KUBE_CONTEXT=%%C"

if not "%KUBE_CONTEXT%"=="kind-sre-lab" (
    echo ERROR: Expected context kind-sre-lab, found %KUBE_CONTEXT%.
    echo Deployment cancelled for safety.
    exit /b 1
)

echo Building local Docker image...
docker build -t fastapi-cicd-platform:1.0.0 .
if errorlevel 1 exit /b 1

echo Loading image into Kind...
kind load docker-image fastapi-cicd-platform:1.0.0 --name sre-lab
if errorlevel 1 exit /b 1

echo Creating namespace if needed...
kubectl create namespace fastapi-platform --dry-run=client -o yaml | kubectl apply -f -
if errorlevel 1 exit /b 1

echo Applying Kubernetes manifests...
kubectl apply -f k8s/
if errorlevel 1 exit /b 1

echo Waiting for rollout...
kubectl rollout status deployment/fastapi-platform -n fastapi-platform --timeout=120s
if errorlevel 1 exit /b 1

echo Deployment complete.
kubectl get deployments,pods,services -n fastapi-platform

endlocal
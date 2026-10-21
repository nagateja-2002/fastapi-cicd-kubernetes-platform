@echo off
setlocal

for /f "delims=" %%C in ('kubectl config current-context') do set "KUBE_CONTEXT=%%C"

if not "%KUBE_CONTEXT%"=="kind-sre-lab" (
    echo ERROR: Expected kind-sre-lab context. Aborting.
    exit /b 1
)

kubectl rollout status deployment/fastapi-platform -n fastapi-platform --timeout=120s
if errorlevel 1 exit /b 1

kubectl port-forward -n fastapi-platform service/fastapi-platform 18000:80
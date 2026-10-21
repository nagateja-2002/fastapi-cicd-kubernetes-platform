@echo off
setlocal

set "CURRENT_CONTEXT="

for /f "delims=" %%C in ('kubectl config current-context 2^>nul') do set "CURRENT_CONTEXT=%%C"

if not "%CURRENT_CONTEXT%"=="kind-sre-lab" (
    echo ERROR: Expected Kubernetes context kind-sre-lab.
    echo Current context: %CURRENT_CONTEXT%
    echo No rollback was performed.
    exit /b 1
)

echo Rolling back the local lab Deployment...
kubectl rollout undo deployment/fastapi-platform -n fastapi-platform

if errorlevel 1 exit /b 1

kubectl rollout status deployment/fastapi-platform -n fastapi-platform
exit /b %ERRORLEVEL%
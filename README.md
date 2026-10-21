# FastAPI CI/CD Kubernetes Platform

A containerized FastAPI application deployed to a local Kubernetes cluster using Kind.

## Features
- FastAPI application with health and Prometheus metrics endpoints
- Docker image built using Python 3.12 slim
- Kubernetes Deployment with two replicas
- Kubernetes ClusterIP Service
- Readiness and liveness probes
- GitHub Actions workflow for tests and Docker image building

## Endpoints
- `/` - Application information
- `/health` - Application health
- `/metrics` - Prometheus application metrics

## Run tests

    .venv\Scripts\python.exe -m pytest app\tests -v

## Deploy locally

Verify the Kubernetes context is kind-sre-lab before deployment.

    scripts\deploy.cmd

## Validation

Four application tests passed locally. The Kubernetes Deployment reached two available replicas during validation.

The GitHub Actions workflow is configured, but a successful hosted run must be verified after publishing the repository.

## Scope

This project demonstrates containerization, Kubernetes deployment, health checks, metrics, testing, and CI automation. It does not currently include a Prometheus server, Grafana dashboard, or automated deployment from hosted CI.

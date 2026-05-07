#!/bin/bash

set -e

echo "🚀 Create k3d cluster..."
#k3d cluster create gitops \
#  -p "8080:80@loadbalancer" \
#  -p "8443:443@loadbalancer"

k3d cluster create gitops \
  -p "8080:80@loadbalancer" \
  -p "8443:443@loadbalancer" \
  --k3s-arg "--disable=traefik@server:0"  

echo "📦 Install ArgoCD..."
kubectl create namespace argocd || true

#kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
kubectl apply --server-side -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

echo "⏳ Waiting ArgoCD..."
kubectl wait --for=condition=available deployment/argocd-server -n argocd --timeout=120s

echo "🌐 Port forward ArgoCD..."
kubectl port-forward svc/argocd-server -n argocd 9090:443 &

echo "✅ Done"
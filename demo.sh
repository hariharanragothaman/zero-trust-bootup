#!/usr/bin/env bash
set -euo pipefail

echo "🚀  Zero‑Trust demo starting..."

#-------------#
# 0. PRECHECK #
#-------------#
command -v istioctl >/dev/null 2>&1 || { echo >&2 "❌ 'istioctl' not found. Install Istio first."; exit 1; }

#------------#
# 1. CLUSTER #
#------------#
if ! kubectl get node >/dev/null 2>&1; then
  echo "⏳  Starting minikube..."
  minikube start --memory 4096 --cpus 4
fi

# Enable sidecar injection
kubectl label namespace default istio-injection=enabled --overwrite

#-----------#
# 2. ISTIO  #
#-----------#
echo "🔧  Installing Istio (demo profile)..."
istioctl install --set profile=demo -y

#-----------#
# 3. SPIRE  #
#-----------#
echo "🔐  Deploying SPIRE..."
kubectl apply -f k8s/spire

# Wait for server ready
echo "⏳  Waiting for SPIRE server..."
kubectl wait --for=condition=available deploy/spire-server -n spire-system --timeout=120s

# Register Echo workload
#kubectl apply -f k8s/spire/registration-job.yaml
echo "✅  SPIRE registration submitted."

#-----------#
# 4. APP    #
#-----------#
echo "📦  Deploying Echo microservice..."
kubectl apply -f k8s/app

#-----------#
# 5. OPA    #
#-----------#
echo "🛡️   Deploying OPA with policy..."
kubectl apply -f k8s/opa

#-----------#
# 6. Gateway#
#-----------#
echo "🚪  Deploying Envoy gateway..."
kubectl apply -f k8s/gateway

#-----------#
# 7. Test   #
#-----------#
echo "🌐  Forwarding ports for local testing..."
kubectl port-forward svc/echo-service 5000:5000 >/dev/null 2>&1 &
kubectl port-forward svc/envoy-gateway 8080:8080 >/dev/null 2>&1 &
echo "🔗  Try:   curl -H 'user: admin' http://localhost:8080/"
echo "🚫  Try:   curl -H 'user: guest' http://localhost:8080/"
echo "📜  View Istio mTLS info:  kubectl logs deploy/echo-service -c istio-proxy | tail"

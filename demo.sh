#!/usr/bin/env bash
set -euo pipefail

echo "🚀  Zero-Trust demo starting..."

#-------------#
# 0. PRECHECK #
#-------------#
for cmd in kubectl istioctl; do
  command -v "$cmd" >/dev/null 2>&1 || { echo >&2 "❌ '$cmd' not found. Please install it first."; exit 1; }
done

#------------#
# 1. CLUSTER #
#------------#
if ! kubectl get node >/dev/null 2>&1; then
  echo "⏳  Starting minikube..."
  minikube start --memory 4096 --cpus 4
fi

kubectl label namespace default istio-injection=enabled --overwrite

#-----------#
# 2. ISTIO  #
#-----------#
echo "🔧  Installing Istio (demo profile)..."
istioctl install --set profile=demo -y

echo "🔒  Enforcing STRICT mTLS..."
kubectl apply -f k8s/istio

#-----------#
# 3. SPIRE  #
#-----------#
echo "🔐  Deploying SPIRE..."
kubectl apply -f k8s/spire/manifest.yaml
kubectl apply -f k8s/spire/agent.yaml

echo "⏳  Waiting for SPIRE server..."
kubectl wait --for=condition=available deploy/spire-server -n spire-system --timeout=120s

echo "📝  Registering Echo workload with SPIRE..."
kubectl apply -f k8s/spire/register-echo.yaml

#-----------#
# 4. APP    #
#-----------#
echo "📦  Deploying Echo microservice..."
kubectl apply -f k8s/app

#-----------#
# 5. OPA    #
#-----------#
echo "🛡️   Deploying OPA (default: allow all)..."
kubectl apply -f k8s/opa

#-----------#
# 6. GATEWAY#
#-----------#
echo "🚪  Deploying Envoy gateway..."
kubectl apply -f k8s/gateway

#-----------#
# 7. WAIT   #
#-----------#
echo "⏳  Waiting for all deployments..."
kubectl wait --for=condition=available deploy/echo-service --timeout=120s
kubectl wait --for=condition=available deploy/opa --timeout=60s
kubectl wait --for=condition=available deploy/envoy-gateway --timeout=60s

#-----------#
# 8. TEST   #
#-----------#
echo ""
echo "✅  All components deployed!"
echo ""
echo "🌐  Forwarding ports for local testing..."
kubectl port-forward svc/echo-service 5000:5000 >/dev/null 2>&1 &
kubectl port-forward svc/envoy-gateway 8080:8080 >/dev/null 2>&1 &
sleep 2

echo ""
echo "=========================================="
echo "  Phase 1: Default Allow (all pass)"
echo "=========================================="
echo "🔗  Try:   curl -H 'user: admin' http://localhost:8080/"
echo "🔗  Try:   curl -H 'user: guest' http://localhost:8080/"
echo ""
echo "=========================================="
echo "  Phase 2: Enforce admin-only policy"
echo "=========================================="
echo "  Run:"
echo "    kubectl create configmap opa-policy \\"
echo "      --from-file=example.rego=policies/opa/example.rego \\"
echo "      --dry-run=client -o yaml | kubectl apply -f -"
echo "    kubectl rollout restart deploy/opa"
echo ""
echo "  Then retry the curl commands above."
echo ""
echo "📜  View Istio mTLS info:  kubectl logs deploy/echo-service -c istio-proxy | tail"

# Live Demo Walk-through

This guide mirrors what `demo.sh` does, broken into individually executable
steps for a live presentation. Pause at each step to explain the zero-trust
layer being added.

---

## 1. Start Cluster + Install Istio

```bash
minikube start --memory 4096 --cpus 4
istioctl install --set profile=demo -y
kubectl label namespace default istio-injection=enabled
```

> **Talking point:** Istio sidecar injection means every pod gets an Envoy
> proxy that handles mTLS transparently.

## 2. Enforce STRICT mTLS

```bash
kubectl apply -f k8s/istio
```

> **Talking point:** `PeerAuthentication` with `mode: STRICT` rejects any
> plain-text traffic inside the mesh.

## 3. Deploy SPIRE

```bash
kubectl apply -f k8s/spire/manifest.yaml
kubectl apply -f k8s/spire/agent.yaml
kubectl wait --for=condition=available deploy/spire-server -n spire-system --timeout=120s
```

> **Talking point:** SPIRE issues short-lived SPIFFE IDs (X.509 SVIDs) to
> workloads — no static secrets, no key rotation headaches.

## 4. Register Echo Workload

```bash
kubectl apply -f k8s/spire/register-echo.yaml
```

> **Talking point:** The registration entry tells SPIRE which SPIFFE ID to
> issue for pods in namespace `default` with service account `echo-service`.

## 5. Deploy Echo Service

```bash
kubectl apply -f k8s/app
```

## 6. Deploy OPA + Envoy Gateway

```bash
kubectl apply -f k8s/opa
kubectl apply -f k8s/gateway
```

## 7. Port-forward and Test (Phase 1 — Allow All)

```bash
kubectl port-forward svc/envoy-gateway 8080:8080 &

# Both pass — default policy is allow-all
curl -H "user: admin" http://localhost:8080/
curl -H "user: guest" http://localhost:8080/
```

> **Talking point:** Right now OPA has `default allow = true`. Every request
> passes. Let's fix that.

## 8. Enforce Admin-Only Policy (Phase 2)

```bash
kubectl create configmap opa-policy \
  --from-file=example.rego=policies/opa/example.rego \
  --dry-run=client -o yaml | kubectl apply -f -

kubectl rollout restart deploy/opa
sleep 5

# Admin passes
curl -H "user: admin" http://localhost:8080/

# Guest is denied
curl -H "user: guest" http://localhost:8080/
```

> **Talking point:** One policy change, zero code changes. That's policy as
> code with OPA.

## 9. Show Istio mTLS Logs

```bash
kubectl logs deploy/echo-service -c istio-proxy | tail
```

> **Talking point:** The istio-proxy sidecar shows the mTLS handshake —
> all traffic is encrypted even though the Flask app knows nothing about TLS.

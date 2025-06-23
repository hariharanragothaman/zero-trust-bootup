# Live Demo Walk‑through

This guide mirrors what `demo.sh` does, but step‑by‑step for a live
presentation.

1. **Start cluster + install Istio**

```bash
minikube start --memory 4096 --cpus 4
istioctl install --set profile=demo -y
kubectl label namespace default istio-injection=enabled
```

2. **Deploy SPIRE**

```bash
kubectl apply -f k8s/spire
kubectl wait --for=condition=available deploy/spire-server -n spire-system --timeout=120s
```

3. **Register Echo workload**

```bash
kubectl apply -f k8s/spire/registration-job.yaml
```

4. **Deploy Echo service**

```bash
kubectl apply -f k8s/app
```

5. **Deploy OPA + Envoy**

```bash
kubectl apply -f k8s/opa
kubectl apply -f k8s/gateway
```

6. **Port‑forward and test**

```bash
kubectl port-forward svc/envoy-gateway 8080:8080 &
curl -H "user: admin" http://localhost:8080/
curl -H "user: guest" http://localhost:8080/
```

7. **Show Istio mTLS logs**

```bash
kubectl logs deploy/echo-service -c istio-proxy | tail
```
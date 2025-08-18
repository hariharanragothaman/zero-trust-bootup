# Zero Trust for APIs & Microservices – Demo

This repository accompanies the talks

**“Zero Trust for APIs and Microservices: Service‑Mesh Security in a Cloud‑Native World.”**       
**“Shift-Left Meets Zero Trust: Building Secure-by-Design APIs from Day Zero.”**


It demonstrates how to combine **SPIRE + SPIFFE** (identity), **Istio** (mTLS/mesh),
**OPA** (policy), and **Envoy** (gateway) on a local Kubernetes cluster
(`minikube` or `kind`).

---

## Quick Start (Minikube)

```bash
# 1. Clone and enter
git clone https://github.com/your‑org/zero-trust-api-demo.git
cd zero-trust-api-demo

# 2. Start Kubernetes (minikube)
minikube start --memory 4096 --cpus 4

# 3. Run the automated script
./demo.sh
```

Within ~3 minutes you’ll have:

* SPIRE server + agent issuing **SPIFFE IDs**
* Istio service‑mesh enforcing **STRICT mTLS**
* Echo microservice with sidecar
* Envoy gateway fronting the mesh
* OPA policy allowing only `user: admin`

---

## Manual Steps (for live walk‑through)

See **[`docs/demo-guide.md`](docs/demo-guide.md)** for a step‑by‑step
terminal script you can run during the talk.

---

## Repo Layout

```
k8s/
├── spire/       # SPIRE server & agent manifests
├── istio/       # mTLS & mesh policies
├── app/         # Echo microservice manifests
├── opa/         # OPA deployment + policy ConfigMap
└── gateway/     # Envoy deployment + config
policies/opa/    # Rego policies (source of truth)
src/             # Sample application code
```

---

## References

* [SPIFFE / SPIRE](https://spiffe.io)
* [Istio Security](https://istio.io/latest/docs/concepts/security/)
* [Open Policy Agent](https://www.openpolicyagent.org/)
* [Envoy Ext‑Authz](https://www.envoyproxy.io/docs/envoy/latest/configuration/http/http_filters/ext_authz_filter)

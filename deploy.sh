#!/bin/bash
set -e

echo "🚀 LLM Pipeline Platform - Deploy Completo"
echo "=========================================="
echo ""

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

# 1. Aplicar manifests base
echo -e "${BLUE}📦 Aplicando manifests base...${NC}"
kubectl apply -f kserve/
kubectl apply -f redis-queue/
kubectl apply -f keras-pipeline/
kubectl apply -f gateway/
kubectl apply -f frontend/
kubectl apply -f Holmegpt/
kubectl apply -f wasm/
kubectl apply -f spinkube/
kubectl apply -f cilium/network-policies.yaml

# 2. Aguardar KServe controller
echo -e "${YELLOW}⏳ Aguardando KServe controller...${NC}"
kubectl wait --for=condition=Available deployment/kserve-controller-manager -n kserve --timeout=120s || true

# 3. Aguardar pods ficarem prontos (com timeout reduzido)
echo -e "${YELLOW}⏳ Aguardando pods...${NC}"
sleep 30

# 4. Reiniciar deployments
echo -e "${BLUE}🔄 Reiniciando deployments...${NC}"
kubectl rollout restart deployment keras-api -n keras-pipeline 2>/dev/null || true
kubectl rollout restart deployment keras-api-v2 -n keras-pipeline 2>/dev/null || true

# 5. Verificar status
echo ""
echo -e "${GREEN}✅ Deploy completo!${NC}"
echo ""
echo "📊 Status dos pods:"
kubectl get pods --all-namespaces | grep -E "kserve|keras|redis|gateway|frontend|holmegpt|wasm|spin" || true

echo ""
echo "🌐 Acessos:"
echo "  ArgoCD:     https://localhost:9090"
echo "  Frontend:   kubectl port-forward svc/frontend -n frontend 8083:80"
echo "  HolmeGPT:    kubectl port-forward svc/holmegpt -n Holmegpt 8084:80"
echo "  Hubble CLI:  ./hubble-observe.sh flows"
echo ""
echo "📁 Novos componentes:"
echo "  HolmeGPT — Chat UI Local WASM"
echo "  WASM Runtime — Runtime para modelos WASM"
echo "  SpinKube — Orquestração WASM (lightweight)"

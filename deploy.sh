#!/bin/bash
set -e

echo "🚀 LLM Pipeline Platform - Deploy Completo"
echo "=========================================="
echo ""

# Cores
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

# 1. Aplicar manifests base
echo -e "${BLUE}📦 Aplicando manifests base...${NC}"
kubectl apply -f kserve/namespace.yaml
kubectl apply -f kserve/pvc.yaml
kubectl apply -f redis-queue/
kubectl apply -f keras-pipeline/namespace.yaml
kubectl apply -f keras-pipeline/model-pvc.yaml
kubectl apply -f gateway/
kubectl apply -f frontend/

# 2. Aguardar KServe controller
echo -e "${YELLOW}⏳ Aguardando KServe controller...${NC}"
kubectl wait --for=condition=Available deployment/kserve-controller-manager -n kserve --timeout=120s

# 3. Aplicar KServe
echo -e "${BLUE}🤖 Aplicando KServe...${NC}"
kubectl apply -f kserve/servingruntime.yaml
kubectl apply -f kserve/inferenceservice.yaml

# 4. Treinar modelo Keras
echo -e "${YELLOW}⏳ Treinando modelo Keras...${NC}"
kubectl apply -f keras-pipeline/train-job.yaml
kubectl wait --for=condition=Complete job/keras-train -n keras-pipeline --timeout=300s

# 5. Aplicar APIs
echo -e "${BLUE}🧠 Aplicando APIs...${NC}"
kubectl apply -f keras-pipeline/api-deployment.yaml
kubectl apply -f keras-pipeline/api-service.yaml

# 6. Aplicar KEDA
echo -e "${BLUE}📈 Aplicando KEDA...${NC}"
kubectl apply -f keda/namespace.yaml
kubectl apply -f keda/scaledobject.yaml
kubectl apply -f keda/canary-deployment.yaml
kubectl apply -f keda/canary-httproute.yaml

# 7. Aplicar Cilium
echo -e "${BLUE}🔒 Aplicando Cilium Network Policies...${NC}"
kubectl apply -f cilium/network-policies.yaml

# 8. Reiniciar deployments
echo -e "${YELLOW}🔄 Reiniciando deployments...${NC}"
kubectl rollout restart deployment keras-api -n keras-pipeline
kubectl rollout restart deployment keras-api-v2 -n keras-pipeline

# 9. Verificar status
echo ""
echo -e "${GREEN}✅ Deploy completo!${NC}"
echo ""
echo "📊 Status dos pods:"
kubectl get pods --all-namespaces | grep -E "kserve|keras|redis|gateway|frontend" || true

echo ""
echo "🌐 Acessos:"
echo "  ArgoCD:     https://localhost:9090"
echo "  Frontend:   kubectl port-forward svc/frontend -n frontend 8083:80"
echo "  Hubble CLI: ./hubble-observe.sh flows"
echo ""
echo "📈 KEDA:"
echo "  kubectl get scaledobject -n keras-pipeline"
echo "  kubectl get hpa -n keras-pipeline"
echo ""
echo "🐤 Canary:"
echo "  90% → keras-api (v1)"
echo "  10% → keras-api-v2 (threshold de confiança)"

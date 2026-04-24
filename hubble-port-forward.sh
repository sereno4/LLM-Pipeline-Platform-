#!/bin/bash

echo "🔍 Hubble UI - Port Forward"
echo "============================"
echo ""

# Verificar se Hubble UI está rodando
if ! kubectl get pods -n cilium-monitoring | grep -q hubble-ui; then
    echo "❌ Hubble UI não encontrado no namespace cilium-monitoring"
    echo "   Aplicando manifests..."
    kubectl apply -f cilium/hubble-ui.yaml
    sleep 10
fi

# Aguardar pod ficar pronto
echo "⏳ Aguardando Hubble UI ficar pronto..."
kubectl wait --for=condition=Ready pod -l app=hubble-ui -n cilium-monitoring --timeout=60s

# Port forward
echo ""
echo "🌐 Acessar Hubble UI em: http://localhost:8085"
echo "   (Ctrl+C para parar)"
echo ""

kubectl port-forward svc/hubble-ui -n cilium-monitoring 8085:80

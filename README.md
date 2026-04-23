# LLM Pipeline Platform

🚀 Plataforma de **MLOps + GitOps** para servir modelos de linguagem (LLMs) em Kubernetes, com sincronização contínua via **ArgoCD**.

---

## 📂 Estrutura do Projeto

- **frontend/** → Interface web para interação com os modelos  
- **gateway/** → Orquestração de requisições e roteamento  
- **keras-pipeline/** → Pipeline de treinamento/inferência com Keras  
- **kserve/** → Servidor de modelos em escala usando KServe  
- **redis-queue/** → Fila assíncrona para processamento distribuído  
- **argocd/** → Manifests de Applications para GitOps  

---

## ⚙️ Fluxo de Deploy

1. **GitHub** → Código e manifests versionados no repositório  
2. **ArgoCD** → Sincroniza automaticamente o estado do cluster com o repositório  
3. **Kubernetes** → Executa os pods e serviços em namespaces dedicados  
4. **Dashboard ArgoCD** → Observabilidade e controle centralizado  

---

## 🚀 Como rodar

### Pré-requisitos
- Kubernetes cluster ativo  
- ArgoCD instalado (`kubectl apply -n argocd -f install.yaml`)  
- Acesso ao repositório via HTTPS ou SSH  

### Deploy das aplicações
```bash
kubectl apply -f argocd/applications/


kubectl get pods -n frontend
kubectl get pods -n gateway
kubectl get pods -n keras-pipeline
kubectl get pods -n kserve
kubectl get pods -n redis-queue


🌐 Tecnologias
Kubernetes

ArgoCD

KServe

Redis

GitOps

MLOps

📊 Endpoints
Table
Serviço	Endpoint	Descrição
GPT-2	/v1/models/gpt2:predict	Geração de texto
Sentiment	/keras/predict?text=...	Análise de sentimento
Queue	/queue	Status da fila Redis
Dashboard	/	Interface visual

📁 Estrutura
kserve/ — ServingRuntime + InferenceService (GPT-2)
keras-pipeline/ — Job de treino + API FastAPI
redis-queue/ — Redis + Celery Workers
gateway/ — Gateway API + HTTPRoutes
frontend/ — Dashboard HTML5
argocd/ — Applications GitOps

┌─────────────────────────────────────────────────────────────┐
│                    ArgoCD Dashboard                          │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐  │
│  │  🔵 KServe  │  │  🟢 Gateway │  │  🟡 Keras Pipeline  │  │
│  │  GPT-2 API  │  │  API Router │  │  + Redis Queue      │  │
│  └─────────────┘  └─────────────┘  └─────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
                              │
        ┌─────────────────────┼─────────────────────┐
        ▼                     ▼                     ▼
   ┌─────────┐          ┌──────────┐         ┌────────────┐
   │  Redis  │◄────────►│  Worker  │◄────────│  Keras   │
   │  Queue  │          │  Celery  │         │  Model   │
   └─────────┘          └──────────┘         └────────────┘

llm-portfolio/
├── README.md                    # Documentação do projeto
├── architecture.png             # Diagrama da arquitetura
├── argocd/
│   └── applications/
│       ├── kserve-app.yaml
│       ├── gateway-app.yaml
│       ├── keras-pipeline-app.yaml
│       └── redis-app.yaml
├── kserve/
│   ├── namespace.yaml
│   ├── pvc.yaml
│   ├── servingruntime.yaml
│   └── inferenceservice.yaml
├── gateway/
│   ├── namespace.yaml
│   ├── gateway.yaml
│   └── httproute.yaml
├── redis-queue/
│   ├── namespace.yaml
│   ├── redis-deployment.yaml
│   ├── redis-service.yaml
│   └── celery-worker.yaml
├── keras-pipeline/
│   ├── namespace.yaml
│   ├── train-job.yaml
│   ├── api-deployment.yaml
│   ├── api-service.yaml
│   └── model-pvc.yaml
└── frontend/
    ├── namespace.yaml
    ├── deployment.yaml
    ├── service.yaml
    └── configmap.yaml

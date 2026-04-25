# 🏥 Lacrei Saúde - Desafio DevOps (Full Stack Infrastructure)

![AWS](https://img.shields.io/badge/AWS-Cloud-orange?logo=amazon-aws)
![Terraform](https://img.shields.io/badge/Terraform-IaC-623CE4?logo=terraform)
![Docker](https://img.shields.io/badge/Docker-Containerization-2496ED?logo=docker)
![GitHub Actions](https://img.shields.io/badge/GitHub_Actions-CI/CD-2088FF?logo=github-actions)
![Node.js](https://img.shields.io/badge/Node.js-Backend-339933?logo=node.js)
![Prometheus](https://img.shields.io/badge/Prometheus-Monitoring-E6522C?logo=prometheus)
![Grafana](https://img.shields.io/badge/Grafana-Dashboard-F46800?logo=grafana)
![ECS](https://img.shields.io/badge/AWS_ECS-Fargate-orange)
![ECR](https://img.shields.io/badge/AWS_ECR-Registry-orange)
![CloudWatch](https://img.shields.io/badge/CloudWatch-Logs-yellow)
![SNS](https://img.shields.io/badge/SNS-Alerts-yellow)

---

Este projeto implementa a infraestrutura moderna e o pipeline de entrega contínua para a API da Lacrei Saúde. A solução utiliza práticas de **IaC (Infrastructure as Code)**, **Cloud Native** e **Observabilidade** para garantir um ambiente seguro, escalável e monitorado.

---

# 🛠️ Tecnologias Utilizadas

## ☁️ Infraestrutura & Cloud

- AWS (Amazon Web Services)
- AWS ECS Fargate
- AWS ECR (Elastic Container Registry)
- AWS VPC (Virtual Private Cloud)
- AWS ALB (Application Load Balancer)
- AWS SNS (Simple Notification Service)
- AWS CloudWatch
- AWS IAM
- AWS S3 & DynamoDB

---

## 🔄 CI/CD & Automação

- Terraform
- GitHub Actions
- Hadolint
- Git

---

## 📦 Aplicação & Monitoramento

- Node.js + Express
- Prom-client (Prometheus)
- Grafana + Prometheus
- Asaas API (mock)
- Docker

---

# 🚀 Setup dos Ambientes

## 1️⃣ Provisionamento com Terraform

```bash
cd terraform
terraform init

# Staging
terraform apply -var="environment=staging" -var="asaas_api_key=$MINHA_CHAVE"
```

---

## 2️⃣ GitHub Secrets

Configure no repositório:

- AWS_ACCESS_KEY_ID  
- AWS_SECRET_ACCESS_KEY  
- ASAAS_API_KEY  
- ACM_CERTIFICATE_ARN

---

# 🔄 Fluxo de CI/CD

Pipeline automatizada:

## 🏗️ Build
- Build da imagem Docker (multi-stage)
- Push para ECR

## 🧪 Testes
- Lint com Hadolint  
- Teste do container (`/status` via curl)

## 🚀 Deploy
- develop → Staging  
- main → Produção  

---

# 🛡️ Segurança

- Container roda como **non-root**
- Subnets privadas (sem IP público)
- IAM com princípio do menor privilégio
- Secrets via variáveis de ambiente
- ECR com criptografia AES256
- HTTPS via ALB + TLS

---

# 📊 Observabilidade

- Logs no CloudWatch
- Métricas via Prometheus
- Dashboards no Grafana
- Alertas via SNS

---

# 🔄 Rollback

## ✔ Automático (ECS Blue/Green)
- Falha no health check → rollback automático

## ✔ Manual
- Re-deploy de versão anterior via pipeline

---

# 💳 Integração com Asaas (Mock)

Exemplo:

```json
{
  "status": "paid",
  "split": true
}
```

---

# 📝 Registro de Decisões

- Problema com `$` na API Key do Asaas  
  → Sanitização via GitHub Secrets  

- Escolha do Fargate  
  → Menor overhead operacional  

- Erro SNS  
  → Adicionada permissão `sns:Publish`  

---

# 👨‍💻 Autor

**Heberton Geovane**  
  
[![LinkedIn](https://img.shields.io/badge/linkedin-%230077B5.svg?style=for-the-badge&logo=linkedin&logoColor=white)](https://linkedin.com/in/heberton-geovane)
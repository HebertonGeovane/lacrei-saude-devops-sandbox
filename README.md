# 🏥 Lacrei Saúde - Desafio Técnico DevOps 

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

Este Desafio Técnico DevOps implementa uma infraestrutura moderna e o pipeline de entrega contínua para a API da Lacrei Saúde. A solução utiliza práticas de **IaC (Infrastructure as Code)**, **Cloud Native** e **Observabilidade** para garantir um ambiente seguro, escalável e monitorado.

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

Durante o desenvolvimento deste teste técnico, enfrentei e resolvi desafios reais de engenharia de nuvem, documentados abaixo para fins de governança e histórico:


### 1. Unificação do Load Balancer (Custo e DNS)
* **Problema:** A criação de múltiplos ALBs gerava custos desnecessários e exigia que o administrador de rede alterasse registros DNS (CNAME) a cada novo ambiente.
* **Solução:** Refatoração do Terraform para utilizar um **Application Load Balancer compartilhado** (`lacrei-alb-main`). Implementado o uso de múltiplos **Target Groups** vinculados ao mesmo Listener, garantindo economia e estabilidade no link oficial.

### 2. Sanitização de Secrets (Interpolação de Bash)
* **Problema:** A chave da API do Asaas continha o caractere especial `$`, que era interpretado erroneamente pelo Linux/Terraform como uma variável de sistema vazia.
* **Solução:** Implementação de **escape sequence** (`\$`) e tratamento rigoroso via GitHub Secrets, garantindo que a credencial fosse entregue à aplicação de forma íntegra.

### 3. Gerenciamento de Estado do ECR (Lifecycle)
* **Problema:** O Terraform apresentava o erro `RepositoryNotEmptyException` ao tentar destruir ou renomear recursos, impedindo deploys automatizados devido à persistência de imagens Docker antigas.
* **Solução:** Adição da flag `force_delete = true` no recurso do **Amazon ECR**. Isso permite que o pipeline limpe o ambiente e recrie repositórios de forma fluida sem intervenção manual.

### 4. Observabilidade Ativa e Resiliência
* **Solução:** Implementação de alarmes de **CloudWatch** integrados ao **Amazon SNS**. Configuração e monitoramento da métrica `UnhealthyHostCount` para garantir que o time de engenharia receba notificações imediatas via e-mail caso os containers de produção apresentem falhas de saúde.

---
# Relatório de Melhorias e Validações Técnicas

Este documento detalha as implementações realizadas para atender aos requisitos de robustez, segurança e resiliência operacional da infraestrutura.

---

### ✅ 1. Monitoramento e Observabilidade
**Requisito:** Evidenciar logs, métricas e alertas.

* **Logs Estruturados:** Implementação e consulta via **CloudWatch Log Insights** para monitorar o bootstrap da aplicação e metadados críticos.
* **Telemetria de Recursos:** Ativação do **Container Insights** para monitoramento granular de consumo de CPU e Memória, permitindo análises de performance e *right-sizing*.
* **Resposta Proativa:** Configuração do ciclo completo de alerta:
    * **Métrica:** `UnhealthyHostCount` (via CloudWatch Alarm).
    * **Notificação:** Integração com **Amazon SNS**.
    * **Evidência Real:** Demonstração do e-mail de alerta disparado em tempo real ao detectar falha de saúde nos containers.

---

### ✅ 2. Fluxo de Rollback Operacional
**Requisito:** Detalhar ou demonstrar o fluxo de reversão de forma operacional.

* **Estratégia Git Revert:** Demonstração técnica da reversão via terminal. Diferente de um reset, o `git revert` gera um novo commit de "cura", mantendo o histórico auditável e seguro.
* **Automação via CI/CD:** O fluxo foi integrado ao pipeline, garantindo que o rollback seja processado automaticamente pelo GitHub Actions, realizando o redeploy da versão estável sem necessidade de intervenção manual no console da AWS.
* **Agilidade:** Redução drástica do **MTTR** (Tempo Médio de Reparo) através de comandos rápidos e deploys automatizados.

---

### ✅ 3. Aspectos de Segurança
**Requisito:** Gestão de secrets, permissões e políticas de acesso.

* **Secrets Management:** Uso do **GitHub Actions Secrets** para criptografia de chaves sensíveis (`ASAAS_API_KEY`, `AWS_CREDENTIALS`, `ACM_CERTIFICATE_ARN`), garantindo que nenhum dado sensível esteja no código-fonte.
* **IAM & Least Privilege:** Implementação de Roles distintas para o ECS:
    * **Execution Role:** Permissões para infraestrutura (ECR/Logs).
    * **Task Role:** Permissões específicas para o código da aplicação (ex: SNS).
* **Segurança de Rede:** Isolamento de containers em **Subnets Privadas** e proteção de tráfego via **HTTPS** utilizando certificados gerenciados pelo **AWS ACM**.

---

### ✅ 4. Validações Adicionais no Pipeline
**Requisito:** Testes automatizados e verificações pré-deploy.

* **Quality Gate (Portão de Qualidade):** Implementação de **Health Check local** com o comando `curl --fail` durante o estágio de teste no GitHub Actions.
* **Linting de Infraestrutura:** Uso do **Hadolint** para garantir que o Dockerfile siga as melhores práticas de segurança e otimização.
* **Cenário de Falha (Shift-Left):** Demonstração real do pipeline interrompendo um deploy após uma falha simulada (Status 500), impedindo que códigos instáveis cheguem ao ambiente de produção.

---
> **Caso Real de Sucesso:** Durante a atualização final desta documentação, o pipeline de CI/CD barrou automaticamente o deploy devido a um erro de compatibilidade (`ERR_REQUIRE_ESM`) entre o Node.js v18 e as novas dependências do AWS SDK v3. 
> 
> **Ação Tomada:** Graças ao Health Check preventivo (Ponto 4), o erro foi isolado no estágio de build. Realizamos o upgrade do runtime para **Node.js v20-slim**, garantindo a compatibilidade e a segurança das bibliotecas de telemetria sem afetar o ambiente produtivo.

# 👨‍💻 Autor

**Heberton Geovane**  
  
[![LinkedIn](https://img.shields.io/badge/linkedin-%230077B5.svg?style=for-the-badge&logo=linkedin&logoColor=white)](https://linkedin.com/in/heberton-geovane)
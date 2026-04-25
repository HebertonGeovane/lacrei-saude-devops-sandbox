# URL do Load Balancer para acessar a API
output "alb_dns_name" {
  description = "DNS público do Load Balancer para acesso à aplicação"
  value       = aws_lb.main.dns_name
}

# URL do Repositório ECR para o GitHub Actions fazer o Push
output "ecr_repository_url" {
  description = "URL do repositório ECR"
  value       = aws_ecr_repository.api.repository_url
}

# Nome do Cluster e Serviço (Úteis para o comando de deploy no GitHub Actions)
output "ecs_cluster_name" {
  value = aws_ecs_cluster.main.name
}

output "ecs_service_name" {
  value = aws_ecs_service.main.name
}
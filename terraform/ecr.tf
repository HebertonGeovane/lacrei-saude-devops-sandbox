resource "aws_ecr_repository" "api" {
  name                 = "lacrei-api-${var.environment}"
  image_tag_mutability = "MUTABLE"

  # Segurança: Escaneia a imagem em busca de vulnerabilidades ao fazer o push
  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "AES256"
  }
}

# Política para limpar imagens antigas e economizar custos
resource "aws_ecr_lifecycle_policy" "api_policy" {
  repository = aws_ecr_repository.api.name

  policy = <<EOF
{
    "rules": [
        {
            "rulePriority": 1,
            "description": "Manter apenas as últimas 5 imagens",
            "selection": {
                "tagStatus": "any",
                "countType": "imageCountMoreThan",
                "countNumber": 5
            },
            "action": {
                "type": "expire"
            }
        }
    ]
}
EOF
}
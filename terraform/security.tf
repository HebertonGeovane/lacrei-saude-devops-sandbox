# Security Group para o Load Balancer (Entrada de tráfego)
resource "aws_security_group" "lb" {
  name        = "lacrei-sg-alb-${var.environment}"
  description = "Controle de acesso para o ALB"
  vpc_id      = module.vpc.vpc_id

  # Permitir HTTP (Para o desafio, depois redirecionamos para HTTPS)
  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Permitir HTTPS (Obrigatório no Checklist)
  ingress {
    protocol    = "tcp"
    from_port   = 443
    to_port     = 443
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Saída livre
  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Security Group para os Containers ECS (Acesso restrito)
resource "aws_security_group" "ecs_tasks" {
  name        = "lacrei-sg-tasks-${var.environment}"
  description = "Permitir acesso apenas vindo do ALB"
  vpc_id      = module.vpc.vpc_id

  ingress {
    protocol        = "tcp"
    from_port       = 3000
    to_port         = 3000
    security_groups = [aws_security_group.lb.id] # Apenas o ALB chega aqui!
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}
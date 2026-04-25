# 1. Cluster ECS
resource "aws_ecs_cluster" "main" {
  name = "lacrei-cluster-${var.environment}"

  setting {
    name  = "containerInsights"
    value = "enabled" 
  }
}

# 2. IAM Roles
# Execution Role: Permite ao ECS baixar a imagem do ECR e criar logs
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "lacrei-ecs-execution-role-${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "ecs-tasks.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Task Role: Permite à aplicação Node.js usar o AWS SDK (ex: enviar SNS)
resource "aws_iam_role" "ecs_task_role" {
  name = "lacrei-ecs-task-role-${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "ecs-tasks.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy" "ecs_sns_publish" {
  name = "lacrei-ecs-sns-policy-${var.environment}"
  role = aws_iam_role.ecs_task_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = "sns:Publish"
        Effect   = "Allow"
        Resource = aws_sns_topic.alerts.arn
      }
    ]
  })
}

# 3. Log Group
resource "aws_cloudwatch_log_group" "api" {
  name              = "/ecs/lacrei-api-${var.environment}"
  retention_in_days = 30
}

# 4. Task Definition
resource "aws_ecs_task_definition" "api" {
  family                   = "lacrei-api-${var.environment}"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn

  container_definitions = jsonencode([
    {
      name      = "api"
      image     = "${aws_ecr_repository.api.repository_url}:latest"
      essential = true
      portMappings = [
        {
          containerPort = 3000
          hostPort      = 3000
        }
      ]
      # INJEÇÃO DA KEY DA ASAAS PARA IMPLEMENTAÇÃO REAL
      environment = [
        { name = "NODE_ENV", value = var.environment },
        { name = "ASAAS_API_KEY", value = var.asaas_api_key },
        { name = "SNS_TOPIC_ARN", value = aws_sns_topic.alerts.arn }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.api.name
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])
}

# 5. ECS Service
resource "aws_ecs_service" "main" {
  name            = "lacrei-service-${var.environment}"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.api.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    security_groups  = [aws_security_group.ecs_tasks.id]
    subnets          = module.vpc.private_subnets
    assign_public_ip = false 
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.api.arn
    container_name   = "api"
    container_port   = 3000
  }
}

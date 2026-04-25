# 1. Tópico SNS para Alertas
resource "aws_sns_topic" "alerts" {
  name = "lacrei-alerts-${var.environment}"
}

# 2. Inscrição (Substitua pelo seu e-mail para testar)
resource "aws_sns_topic_subscription" "email_alert" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = "heberton.geovane@gmail.com" #coloque seu e-mail aqui
}

# 3. Alarme de Saúde da API (Unhealthy Host)
resource "aws_cloudwatch_metric_alarm" "api_unhealthy" {
  alarm_name          = "lacrei-api-unhealthy-${var.environment}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "UnHealthyHostCount"
  namespace           = "AWS/ApplicationELB"
  period              = "60"
  statistic           = "Average"
  threshold           = "1"
  alarm_description   = "Este alarme dispara se o container da Lacrei Saúde estiver offline"
  
  dimensions = {
    TargetGroup  = aws_lb_target_group.api.arn_suffix
    LoadBalancer = aws_lb.main.arn_suffix
  }

  alarm_actions = [aws_sns_topic.alerts.arn]
}
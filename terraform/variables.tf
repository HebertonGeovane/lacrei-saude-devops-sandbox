variable "aws_region" {
  default = "us-east-1"
}

variable "environment" {
  description = "staging ou production"
  type        = string
}

variable "asaas_api_key" {
  description = "Chave da API do Asaas"
  type        = string
  sensitive   = true # Impede que a chave apareça nos logs do console
}

variable "certificate_arn" {
  description = "ARN do certificado gerado no ACM"
  type        = string
  default     = "" # Começa vazio para não quebrar o plano inicial
}
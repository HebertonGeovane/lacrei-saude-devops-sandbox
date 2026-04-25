terraform {
  required_version = ">= 1.0.0"

  backend "s3" {
    bucket         = "lacrei-saude-terraform-state-heberton"
    key            = "state/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "lacrei-saude-terraform-state-locking"
    encrypt        = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }  
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project   = "LacreiSaude-Desafio"
      ManagedBy = "Terraform"
      Owner     = "Heberton"
    }
  }
}
# 1. Bucket S3 para o State
resource "aws_s3_bucket" "terraform_state" {
  bucket = "lacrei-saude-terraform-state-heberton" 

  # Previne a deleção acidental do bucket
  lifecycle {
    prevent_destroy = true
  }
}

# Habilitar versionamento para  recuperar estados antigos
resource "aws_s3_bucket_versioning" "enabled" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

# 2. Tabela DynamoDB para o Lock
resource "aws_dynamodb_table" "terraform_locks" {
  name         = "lacrei-saude-terraform-state-locking"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}
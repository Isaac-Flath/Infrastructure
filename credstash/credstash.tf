
resource "aws_dynamodb_table" "db_credstash" {
  name           = "credential-store"
  read_capacity  = 1
  write_capacity = 1
  hash_key       = "name"
  range_key      = "version"
  attribute {
    name = "name"
    type = "S"
  }
  attribute {
    name = "version"
    type = "S"
  }
  # lifecycle {
  #   prevent_destroy = true
  # }
}
output "arn" { value = aws_dynamodb_table.db_credstash.arn }

resource "aws_kms_key" "credstash" {
  description             = "KMS key for credstash"
  deletion_window_in_days = 10
  is_enabled              = true
}

resource "aws_kms_alias" "credstash" {
  name          = "alias/credstash"
  target_key_id = aws_kms_key.credstash.key_id
}

resource "aws_iam_role" "credstash" {
  name = "credstash"
  assume_role_policy = jsonencode({
    Version : "2012-10-17",
    Statement : [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow",
        Sid    = ""
        Principal = {
          Service : "ec2.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "credstash" {
  role       = aws_iam_role.credstash.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
}


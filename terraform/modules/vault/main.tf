data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

# Security Group for Vault
resource "aws_security_group" "vault" {
  name_prefix = "${var.project_name}-vault-sg"
  vpc_id      = var.vpc_id
  description = "Allow inbound traffic to Vault"

  # Vault UI/API
  ingress {
    from_port   = 8200
    to_port     = 8200
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidr_blocks
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidr_blocks # Restrict this in production
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-vault-sg"
  }
}

# IAM Role for Vault
resource "aws_iam_role" "vault_role" {
  name = "${var.project_name}-vault-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy" "vault_policy" {
  name        = "${var.project_name}-vault-policy"
  description = "Policy for Vault to access DynamoDB and KMS"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:DescribeTable",
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:DeleteItem",
          "dynamodb:UpdateItem",
          "dynamodb:Scan",
          "dynamodb:Query",
          "dynamodb:BatchWriteItem"
        ]
        Resource = "arn:aws:dynamodb:${data.aws_region.current.id}:${data.aws_caller_identity.current.account_id}:table/${aws_dynamodb_table.vault.name}"
      },
      {
        Effect = "Allow"
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:DescribeKey"
        ]
        Resource = "*" # Scope down in prod
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "vault_attach" {
  role       = aws_iam_role.vault_role.name
  policy_arn = aws_iam_policy.vault_policy.arn
}

resource "aws_iam_instance_profile" "vault_profile" {
  name = "${var.project_name}-vault-profile"
  role = aws_iam_role.vault_role.name
}

# DynamoDB Backend
resource "aws_dynamodb_table" "vault" {
  name         = "vault-backend-${var.project_name}"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "Path"
  range_key    = "Key"

  attribute {
    name = "Path"
    type = "S"
  }

  attribute {
    name = "Key"
    type = "S"
  }

  tags = {
    Name = "${var.project_name}-vault-backend"
  }
}

# Vault EC2 Instance
resource "aws_instance" "vault" {
  ami           = "ami-05efc83cb5512477c" # Amazon Linux 2023 (us-east-2)
  instance_type = "t3.micro"
  subnet_id     = var.subnet_ids[0]

  vpc_security_group_ids = [aws_security_group.vault.id]
  iam_instance_profile   = aws_iam_instance_profile.vault_profile.name

  # Optional: SSH Key
  # key_name = aws_key_pair.generated.key_name

  user_data = <<-EOF
              #!/bin/bash
              yum install -y yum-utils
              yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
              yum -y install vault
              
              # Config Vault
              cat <<EOT > /etc/vault.d/vault.hcl
              storage "dynamodb" {
                region = "${data.aws_region.current.id}"
                table = "${aws_dynamodb_table.vault.name}"
              }
              
              listener "tcp" {
                address     = "0.0.0.0:8200"
                tls_disable = 1
              }
              
              ui = true
              disable_mlock = true
              EOT
              
              systemctl enable vault
              systemctl start vault
              EOF

  tags = {
    Name = "vault-instance" # Critical: Pipeline searches for this tag
  }
}

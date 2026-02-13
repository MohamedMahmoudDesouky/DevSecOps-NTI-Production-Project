output "vault_public_ip" {
  value = aws_instance.vault.public_ip
}

output "vault_dynamodb_table_name" {
  value = aws_dynamodb_table.vault.name
}

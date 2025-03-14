output "key_arn" {
  description = "The Amazon Resource Name (ARN) of the key"
  value       = try(aws_kms_key.this[0].arn)
}

output "key_id" {
  description = "The globally unique identifier for the key"
  value       = try(aws_kms_key.this[0].key_id)
}

output "key_policy" {
  description = "The IAM resource policy set on the key"
  value       = try(aws_kms_key.this[0].policy)
}

# Alias

output "aliases" {
  description = "A map of aliases created and their attributes"
  value       = aws_kms_alias.this
}

# Grant

output "grants" {
  description = "A map of grants created and their attributes"
  value       = aws_kms_grant.this
  sensitive   = true
}

# EC2

output "ec2_public_ip" {
  value = aws_instance.ec2.public_ip
}

output "ec2_public_dns" {
  value = aws_instance.ec2.public_dns
}
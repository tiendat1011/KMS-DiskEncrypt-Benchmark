locals {
  iops                 = contains(["io1", "io2", "gp3"], var.type) ? var.iops : 0
  multi_attach_enabled = contains(["io1", "io2"], var.type) ? var.multi_attach_enabled : false
}

resource "aws_ebs_volume" "encrypted_volume" {
  availability_zone    = var.availability_zone
  encrypted            = var.encrypted
  final_snapshot       = var.final_snapshot
  iops                 = local.iops
  multi_attach_enabled = local.multi_attach_enabled
  size                 = var.size
  snapshot_id          = var.snapshot_id
  type                 = var.type
  kms_key_id           = aws_kms_key.this[0].arn
  tags                 = var.volume_tags

  depends_on = [aws_kms_key.this]
}

# resource "aws_ebs_volume" "nonencrypted_volume" {
#   availability_zone = var.availability_zone
#   final_snapshot = var.final_snapshot
#   iops = local.iops
#   multi_attach_enabled = local.multi_attach_enabled
#   size = var.size
#   snapshot_id = var.snapshot_id
#   type = var.type
#   tags = var.volume_tags

# }

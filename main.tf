data "aws_partition" "current" {
  count = var.create ? 1 : 0
}
data "aws_caller_identity" "current" {
  count = var.create ? 1 : 0
}

locals {
  account_id       = try(data.aws_caller_identity.current[0].account_id, "")
  partition        = try(data.aws_partition.current[0].partition, "")
  dns_suffix       = try(data.aws_partition.current[0].dns_suffix, "")
  current_identity = try(data.aws_caller_identity.current[0].arn, "")
}

# Key

resource "aws_kms_key" "this" {
  count = var.create ? 1 : 0

  bypass_policy_lockout_safety_check = var.bypass_policy_lockout_safety_check
  customer_master_key_spec           = var.customer_master_key_spec
  custom_key_store_id                = var.custom_key_store_id
  deletion_window_in_days            = var.deletion_window_in_days
  description                        = var.description
  enable_key_rotation                = var.enable_key_rotation
  is_enabled                         = var.is_enabled
  key_usage                          = var.key_usage
  multi_region                       = var.multi_region
  policy                             = coalesce(var.policy, data.aws_iam_policy_document.this[0].json)
  rotation_period_in_days            = var.rotation_period_in_days

  tags = var.kms_tags
}

data "aws_iam_policy_document" "this" {
  count = var.create ? 1 : 0

  source_policy_documents   = var.source_policy_documents
  override_policy_documents = var.override_policy_documents

  # Default policy - account wide access to all key operations
  dynamic "statement" {
    for_each = var.enable_default_policy ? [1] : []

    content {
      sid       = "Default"
      actions   = ["kms:*"]
      resources = ["*"]

      principals {
        type        = "AWS"
        identifiers = ["arn:${local.partition}:iam::${local.account_id}:root"]
      }
    }
  }

  # Key owner - all key operations
  dynamic "statement" {
    for_each = length([local.current_identity]) > 0 ? [1] : []

    content {
      sid       = "KeyOwner"
      actions   = ["kms:*"]
      resources = ["*"]

      principals {
        type        = "AWS"
        identifiers = [local.current_identity]
      }
    }
  }

  # Key administrators - https://docs.aws.amazon.com/kms/latest/developerguide/key-policy-default.html#key-policy-default-allow-administrators
  dynamic "statement" {
    for_each = length([local.current_identity]) > 0 ? [1] : []

    content {
      sid = "KeyAdministration"
      actions = [
        "kms:Create*",
        "kms:Describe*",
        "kms:Enable*",
        "kms:List*",
        "kms:Put*",
        "kms:Update*",
        "kms:Revoke*",
        "kms:Disable*",
        "kms:Get*",
        "kms:Delete*",
        "kms:TagResource",
        "kms:UntagResource",
        "kms:ScheduleKeyDeletion",
        "kms:CancelKeyDeletion",
        "kms:ReplicateKey",
        "kms:ImportKeyMaterial"
      ]
      resources = ["*"]

      principals {
        type        = "AWS"
        identifiers = [local.current_identity]
      }
    }
  }

  # Key users - https://docs.aws.amazon.com/kms/latest/developerguide/key-policy-default.html#key-policy-default-allow-users
  dynamic "statement" {
    for_each = length([local.current_identity]) > 0 ? [1] : []

    content {
      sid = "KeyUsage"
      actions = [
        "kms:Encrypt",
        "kms:Decrypt",
        "kms:ReEncrypt*",
        "kms:GenerateDataKey*",
        "kms:DescribeKey",
      ]
      resources = ["*"]

      principals {
        type        = "AWS"
        identifiers = [local.current_identity]
      }
    }
  }

  # Key service users - https://docs.aws.amazon.com/kms/latest/developerguide/key-policy-default.html#key-policy-service-integration
  dynamic "statement" {
    for_each = length([local.current_identity]) > 0 ? [1] : []

    content {
      sid = "KeyServiceUsage"
      actions = [
        "kms:CreateGrant",
        "kms:ListGrants",
        "kms:RevokeGrant",
      ]
      resources = ["*"]

      principals {
        type        = "AWS"
        identifiers = [local.current_identity]
      }

      condition {
        test     = "Bool"
        variable = "kms:GrantIsForAWSResource"
        values   = [true]
      }
    }
  }

}

# Alias

locals {
  aliases = { for k, v in toset(var.aliases) : k => { name = v } }
}

resource "aws_kms_alias" "this" {
  for_each = { for k, v in merge(local.aliases, var.computed_aliases) : k => v if var.create }

  name          = var.aliases_use_name_prefix ? null : "alias/${each.value.name}"
  name_prefix   = var.aliases_use_name_prefix ? "alias/${each.value.name}-" : null
  target_key_id = try(aws_kms_key.this[0].key_id)
}

# Grant

resource "aws_kms_grant" "this" {
  for_each = { for k, v in var.grants : k => v if var.create }

  name              = try(each.value.name, each.key)
  key_id            = try(aws_kms_key.this[0].key_id)
  grantee_principal = each.value.grantee_principal
  operations        = each.value.operations

  dynamic "constraints" {
    for_each = length(lookup(each.value, "constraints", {})) == 0 ? [] : [each.value.constraints]

    content {
      encryption_context_equals = try(constraints.value.encryption_context_equals, null)
      encryption_context_subset = try(constraints.value.encryption_context_subset, null)
    }
  }

  retiring_principal    = try(each.value.retiring_principal, null)
  grant_creation_tokens = try(each.value.grant_creation_tokens, null)
  retire_on_delete      = try(each.value.retire_on_delete, null)
}
variable "create" {
  description = "Determines whether resources will be created (affects all resources)"
  type        = bool
  default     = true
}

variable "kms_tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

variable "bypass_policy_lockout_safety_check" {
  description = "A flag to indicate whether to bypass the key policy lockout safety check. Setting this value to true increases the risk that the KMS key becomes unmanageable"
  type        = bool
  default     = null
}

variable "customer_master_key_spec" {
  description = "Specifies whether the key contains a symmetric key or an asymmetric key pair and the encryption algorithms or signing algorithms that the key supports. Valid values: `SYMMETRIC_DEFAULT`, `RSA_2048`, `RSA_3072`, `RSA_4096`, `HMAC_256`, `ECC_NIST_P256`, `ECC_NIST_P384`, `ECC_NIST_P521`, or `ECC_SECG_P256K1`. Defaults to `SYMMETRIC_DEFAULT`"
  type        = string
  default     = null
}

variable "custom_key_store_id" {
  description = "ID of the KMS Custom Key Store where the key will be stored instead of KMS (eg CloudHSM)."
  type        = string
  default     = null
}

variable "deletion_window_in_days" {
  description = "The waiting period, specified in number of days. After the waiting period ends, AWS KMS deletes the KMS key. If you specify a value, it must be between `7` and `30`, inclusive. If you do not specify a value, it defaults to `30`"
  type        = number
  default     = null
}

variable "description" {
  description = "The description of the key as viewed in AWS console"
  type        = string
  default     = null
}

variable "enable_key_rotation" {
  description = "Specifies whether key rotation is enabled. Defaults to `true`"
  type        = bool
  default     = true
}

variable "is_enabled" {
  description = "Specifies whether the key is enabled. Defaults to `true`"
  type        = bool
  default     = null
}
variable "key_usage" {
  description = "Specifies the intended use of the key. Valid values: `ENCRYPT_DECRYPT` or `SIGN_VERIFY`. Defaults to `ENCRYPT_DECRYPT`"
  type        = string
  default     = null
}

variable "multi_region" {
  description = "Indicates whether the KMS key is a multi-Region (`true`) or regional (`false`) key. Defaults to `false`"
  type        = bool
  default     = false
}

variable "policy" {
  description = "A valid policy JSON document. Although this is a key policy, not an IAM policy, an `aws_iam_policy_document`, in the form that designates a principal, can be used"
  type        = string
  default     = null
}

variable "rotation_period_in_days" {
  description = "Custom period of time between each rotation date. Must be a number between 90 and 2560 (inclusive)"
  type        = number
  default     = null
}

variable "source_policy_documents" {
  description = "List of IAM policy documents that are merged together into the exported document. Statements must have unique `sid`s"
  type        = list(string)
  default     = []
}

variable "override_policy_documents" {
  description = "List of IAM policy documents that are merged together into the exported document. In merging, statements with non-blank `sid`s will override statements with the same `sid`"
  type        = list(string)
  default     = []
}

variable "enable_default_policy" {
  description = "Specifies whether to enable the default key policy. Defaults to `true`"
  type        = bool
  default     = true
}

variable "key_owners" {
  description = "A list of IAM ARNs for those who will have full key permissions (`kms:*`)"
  type        = list(string)
  default     = []
}

variable "key_administrators" {
  description = "A list of IAM ARNs for [key administrators](https://docs.aws.amazon.com/kms/latest/developerguide/key-policy-default.html#key-policy-default-allow-administrators)"
  type        = list(string)
  default     = []
}

variable "key_users" {
  description = "A list of IAM ARNs for [key users](https://docs.aws.amazon.com/kms/latest/developerguide/key-policy-default.html#key-policy-default-allow-users)"
  type        = list(string)
  default     = []
}

variable "key_service_users" {
  description = "A list of IAM ARNs for [key service users](https://docs.aws.amazon.com/kms/latest/developerguide/key-policy-default.html#key-policy-service-integration)"
  type        = list(string)
  default     = []
}

# Alias

variable "aliases" {
  description = "A list of aliases to create. Note - due to the use of `toset()`, values must be static strings and not computed values"
  type        = list(string)
  default     = []
}

variable "computed_aliases" {
  description = "A map of aliases to create. Values provided via the `name` key of the map can be computed from upstream resources"
  type        = any
  default     = {}
}

variable "aliases_use_name_prefix" {
  description = "Determines whether the alias name is used as a prefix"
  type        = bool
  default     = false
}

# Grant

variable "grants" {
  description = "A map of grant definitions to create"
  type        = any
  default     = {}
}

# Volume

variable "name" {
  type        = string
  description = "Name of ebs volume"
  default     = "example"
}

variable "availability_zone" {
  type        = string
  description = "Availability Zone where EBS volume will exist."
}

variable "encrypted" {
  type        = bool
  default     = false
  description = "If true, the disk will be encrypted."
}

variable "final_snapshot" {
  type        = bool
  default     = false
  description = <<EOT
If true, snapshot will be created before volume deletion.
Any tags on the volume will be migrated to the snapshot. **BE AWARE** by default is set to `false`.
EOT
}

variable "iops" {
  type        = number
  default     = 0
  description = "Amount of IOPS to provision for the disk. Only valid for `type` of `io1`, `io2` or `gp3`."
}


variable "multi_attach_enabled" {
  type        = bool
  default     = false
  description = "Specifies whether to enable Amazon EBS Multi-Attach. Multi-Attach is supported on `io1` and `io2` volumes."
}

variable "size" {
  type        = number
  description = "The size of the drive in GiBs"
  default     = 8
}

variable "snapshot_id" {
  type        = string
  default     = ""
  description = "A snapshot to base the EBS volume off of"
}

variable "type" {
  type        = string
  default     = "gp2"
  description = "The type of EBS volume. Can be `standard`, `gp2`, `gp3`, `io1`, `io2`, `sc1` or `st1` (Default: `gp2`)"

  validation {
    condition     = contains(["standard", "gp2", "gp3", "io1", "io2", "sc1", "st1"], var.type)
    error_message = "Invalid input, options: standard, gp2, gp3, io1, io2, sc1 or st1."
  }
}

variable "kms_key_id" {
  type        = string
  default     = ""
  description = <<EOT
The ARN for the KMS encryption key. When specifying `kms_key_id`, `encrypted` needs to be set to **true**.
Note: Terraform must be running with credentials which have the `GenerateDataKeyWithoutPlaintext` permission on the specified KMS key
as required by the [EBS KMS CMK volume provisioning process](https://docs.aws.amazon.com/kms/latest/developerguide/services-ebs.html#ebs-cmk) to prevent a volume from being created and almost
immediately deleted.
EOT
}

variable "volume_tags" {
  type        = map(string)
  description = "extra tags"
  default     = {}
}

# Key pair
variable "algorithm" {
  type        = string
  description = "value"
  default     = "RSA"
}

variable "rsa_bits" {
  type        = number
  description = "value"
  default     = 2048
}

variable "key_name" {
  description = "Key name of the Key Pair to use for the instance; which can be managed using the `aws_key_pair` resource"
  type        = string
  default     = null
}

variable "file_permission" {
  type        = string
  description = "value"
  default     = "0600"
}
# EC2 Instance

variable "ami" {
  description = "ID of AMI to use for the instance"
  type        = string
  default     = null
}

variable "instance_type" {
  description = "The type of instance to start"
  type        = string
  default     = "t2.micro"
}

variable "ec2_tags" {
  type        = map(string)
  description = "extra tags"
  default     = {}
}

variable "device_name" {
  type        = string
  description = "value"
  default     = "/dev/xvdf"
}

resource "aws_sns_topic" "sns" {
  name              = var.name
  kms_master_key_id = "alias/ops/sns"
}
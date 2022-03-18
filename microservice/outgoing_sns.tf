// Create outgoing topic
resource "aws_sns_topic" "outgoing_exceptions_topic" {
  name                        = var.outgoing_topic_name
  kms_master_key_id           = data.aws_kms_alias.sns_key.id
  fifo_topic                  = true
  content_based_deduplication = true
}
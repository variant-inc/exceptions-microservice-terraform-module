// Create temporary incoming topic
resource "aws_sns_topic" "incoming_topic_resource" {
  name              = var.incoming_topic_name
  kms_master_key_id = data.aws_kms_alias.sns_key.id
}

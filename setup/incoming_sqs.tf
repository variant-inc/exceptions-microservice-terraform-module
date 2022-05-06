resource "aws_sqs_queue" "entity_topic_deadletter_queue" {
  name                        = var.incoming_deadletter_queue_name
  kms_master_key_id           = data.aws_kms_alias.sns_key.id
  message_retention_seconds   = var.entity_queue_deadletter_retention_seconds
}

# SQS Entity API queue AWS permissions policy.
data "aws_iam_policy_document" "incoming_entity_api_queue_policy_data" {
  policy_id = var.incoming_queue_name
  version   = var.aws_policy_version
  statement {
    effect    = "Allow"
    resources = [aws_sqs_queue.temp_incoming_queue.arn]
    actions   = ["sqs:SendMessage"]

    principals {
      identifiers = ["*"]
      type        = "*"
    }

    condition {
      test     = "ArnEquals"
      values   = [aws_sns_topic.incoming_topic_resource.arn]
      variable = "aws:SourceArn"
    }
  }
}

resource "aws_sqs_queue" "temp_incoming_queue" {
  name                        = var.incoming_queue_name
  kms_master_key_id           = data.aws_kms_alias.sns_key.id
  message_retention_seconds   = var.entity_queue_retention_seconds

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.entity_topic_deadletter_queue.arn
    maxReceiveCount     = 5
  })
}

resource "aws_sqs_queue_policy" "temp_incoming_queue_policy" {
  policy    = data.aws_iam_policy_document.incoming_entity_api_queue_policy_data.json
  queue_url = aws_sqs_queue.temp_incoming_queue.id
}

resource "aws_sns_topic_subscription" "ticketing_handler_subscription" {
  endpoint             = aws_sqs_queue.temp_incoming_queue.arn
  protocol             = "sqs"
  topic_arn            = aws_sns_topic.incoming_topic_resource.arn
  raw_message_delivery = false
  depends_on           = [aws_sqs_queue_policy.temp_incoming_queue_policy]
}

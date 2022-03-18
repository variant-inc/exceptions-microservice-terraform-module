# SQS Entity API queue AWS permissions policy.
data "aws_iam_policy_document" "temp_outgoing_queue_policy_data" {
  policy_id = "temp_outgoing_policy"
  version   = var.aws_policy_version
  statement {
    effect    = "Allow"
    resources = [aws_sqs_queue.temp_outgoing_queue.arn]
    actions   = ["sqs:SendMessage"]

    principals {
      identifiers = ["*"]
      type        = "*"
    }

    condition {
      test     = "ArnEquals"
      values   = [aws_sns_topic.temp_outgoing_exceptions_topic.arn]
      variable = "aws:SourceArn"
    }
  }
}

resource "aws_sqs_queue" "temp_outgoing_queue" {
  name                        = var.outgoing_queue_name
  kms_master_key_id           = data.aws_kms_alias.sns_key.id
  fifo_queue                  = true
  content_based_deduplication = true
  visibility_timeout_seconds  = 3
  message_retention_seconds   = 60
}

resource "aws_sqs_queue_policy" "temp_outgoing_queue_policy" {
  policy    = data.aws_iam_policy_document.temp_outgoing_queue_policy_data.json
  queue_url = aws_sqs_queue.temp_outgoing_queue.id
}

resource "aws_sns_topic_subscription" "outgoing_topic_subscription" {
  endpoint             = aws_sqs_queue.temp_outgoing_queue.arn
  protocol             = "sqs"
  topic_arn            = aws_sns_topic.temp_outgoing_exceptions_topic.arn
  raw_message_delivery = true
  depends_on           = [aws_sqs_queue_policy.temp_outgoing_queue_policy]
}
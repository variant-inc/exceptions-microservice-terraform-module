data "aws_sns_topic" "incoming_topic_data" {
  name = var.incoming_topic_name
}

resource "aws_sqs_queue" "sqs_deadletter" {
  name                        = "${var.name}-deadletter"
  kms_master_key_id           = "alias/ops/sqs"
  message_retention_seconds   = var.entity_queue_deadletter_retention_seconds
}

resource "aws_sqs_queue" "incoming_sqs" {
    name              = var.name
    kms_master_key_id = "alias/ops/sqs"
    message_retention_seconds   = var.incoming_queue_retention_seconds

    redrive_policy = jsonencode({
        deadLetterTargetArn = aws_sqs_queue.sqs_deadletter.arn
        maxReceiveCount     = var.max_receive_count
    })
}

data "aws_iam_policy_document" "sqs_queue_policy_data" {
  policy_id = var.name
  version   = var.aws_policy_version
  statement {
    effect    = "Allow"
    resources = [aws_sqs_queue.incoming_sqs.arn]
    actions   = ["sqs:SendMessage"]

    principals {
      identifiers = ["*"]
      type        = "*"
    }

    condition {
      test     = "ArnEquals"
      values   = [data.aws_sns_topic.incoming_topic_data.arn]
      variable = "aws:SourceArn"
    }
  }
}

resource "aws_sqs_queue_policy" "incoming_entity_queue_policy" {
  policy    = data.aws_iam_policy_document.sqs_queue_policy_data.json
  queue_url = aws_sqs_queue.incoming_sqs.id
}

resource "aws_sns_topic_subscription" "solutions_orchestrator_subscription" {
  endpoint             = aws_sqs_queue.incoming_sqs.arn
  protocol             = "sqs"
  topic_arn            = data.aws_sns_topic.incoming_topic_data.arn
  raw_message_delivery = true
  depends_on           = [aws_sqs_queue_policy.incoming_entity_queue_policy]
}

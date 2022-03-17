# Application AWS Role
resource "aws_iam_role" "application_policy" {
  name               = var.aws_iam_role_name
  // var.environment is set by scripts/octo/plan.sh & delpoy.sh
  description        = "IAM role for ${var.aws_iam_role_name} in ${var.environment} environment"
  assume_role_policy = data.aws_iam_policy_document.instance_assume_role_policy.json

  inline_policy {
    name = var.project_name
    policy = data.aws_iam_policy_document.application_policy_document.json
  }
}

data "aws_iam_policy_document" "application_policy_document" {
  version = var.aws_policy_version

  // Allow SNS Access & permissions
  statement {
    effect = "Allow"
    resources = [
      aws_sns_topic.outgoing_exceptions_topic.arn
    ]
    actions = ["sns:Publish"]
  }

  statement {
    effect = "Allow"
    resources = [
      data.aws_kms_alias.sns_key.target_key_arn,
    ]
    actions = [
      "kms:GenerateDataKey",
      "kms:Decrypt"
    ]
  }

  // Allow SQS Access & permissions
  statement {
    effect = "Allow"
    resources = [
      aws_sqs_queue.incoming_entity_queue.arn
    ]
    actions = [
      "sqs:ChangeMessageVisibility",
      "sqs:ChangeMessageVisibilityBatch",
      "sqs:DeleteMessage",
      "sqs:GetQueueAttributes",
      "sqs:ReceiveMessage"
    ]
  }
}

// var.oidc_provider is set by scripts/octo/plan.sh & delpoy.sh
data "aws_iam_policy_document" "instance_assume_role_policy" {
  version = var.aws_policy_version
  statement {
    effect = "Allow"
    principals {
      identifiers = ["arn:aws:iam::${local.aws_account_id}:oidc-provider/${var.oidc_provider}"]
      type = "Federated"
    }
    actions = ["sts:AssumeRoleWithWebIdentity"]
    condition {
      test = "StringEquals"
      values = ["system:serviceaccount:${var.target_namespace}:${var.k8s_serviceaccount}"]
      variable = "${var.oidc_provider}:sub"
    }
  }
}
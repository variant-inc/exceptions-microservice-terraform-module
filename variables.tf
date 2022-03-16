variable "aws_iam_role_name" {
  type  = string
}

variable "environment" {
  type  = string
}

variable "sns_topic_name" {
  description = "Name of the SNS topic"
  type        = string
}

variable "sqs_queue_name" {
  description = "Name of the SQS queue"
  type        = string
}

variable "user_tags" {
  description = "Mandatory tags for all resources"
  type        = map(string)
}

variable "octopus_tags" {
  description = "Octopus Tags"
  type        = map(string)
}
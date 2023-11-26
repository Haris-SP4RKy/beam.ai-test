##
## Managed policies that allow access to the queue
##

##
##  PROCESS ORDER QUEUE
##
resource "aws_iam_policy" "consumer_policy_process_order_queue" {
  name        = "SQS-consumer_process_order_queue-${var.environment}-${var.region}-consumer_policy"
  description = "Attach this policy to consumers of process_order_queue"
  policy      = data.aws_iam_policy_document.consumer_policy_process_order_queue.json
}

data "aws_iam_policy_document" "consumer_policy_process_order_queue" {
  statement {
    actions = [
      "sqs:ChangeMessageVisibility",
      "sqs:ChangeMessageVisibilityBatch",
      "sqs:DeleteMessage",
      "sqs:DeleteMessageBatch",
      "sqs:GetQueueAttributes",
      "sqs:GetQueueUrl",
      "sqs:ReceiveMessage"
    ]
    resources = [
      aws_sqs_queue.process_order_queue.arn,
      aws_sqs_queue.process_order_deadletter_queue.arn
    ]
  }
}


resource "aws_iam_policy" "producer_policy_process_order_queue" {
  name        = "SQS-process_order_queue-${var.environment}-${var.region}-producer"
  description = "Attach this policy to producers for process_order_queue"
  policy      = data.aws_iam_policy_document.producer_policy_process_order_queue.json
}

data "aws_iam_policy_document" "producer_policy_process_order_queue" {
  statement {
    actions = [
      "sqs:GetQueueAttributes",
      "sqs:GetQueueUrl",
      "sqs:SendMessage",
      "sqs:SendMessageBatch"
    ]
    resources = [
      aws_sqs_queue.process_order_queue.arn
    ]
  }
}



##
##  update_stock_queue
##
resource "aws_iam_policy" "consumer_policy_update_stock_queue" {
  name        = "SQS-update_stock_queue-${var.environment}-${var.region}-consumer_policy"
  description = "Attach this policy to consumers of update_stock_queue"
  policy      = data.aws_iam_policy_document.consumer_policy_update_stock_queue.json
}

data "aws_iam_policy_document" "consumer_policy_update_stock_queue" {
  statement {
    actions = [
      "sqs:ChangeMessageVisibility",
      "sqs:ChangeMessageVisibilityBatch",
      "sqs:DeleteMessage",
      "sqs:DeleteMessageBatch",
      "sqs:GetQueueAttributes",
      "sqs:GetQueueUrl",
      "sqs:ReceiveMessage"
    ]
    resources = [
      aws_sqs_queue.update_stock_queue.arn,
      aws_sqs_queue.process_order_deadletter_queue.arn
    ]
  }
}


resource "aws_iam_policy" "producer_policy_update_stock_queue" {
  name        = "SQS-update_stock_queue-${var.environment}-${var.region}-producer"
  description = "Attach this policy to producers for update_stock_queue"
  policy      = data.aws_iam_policy_document.producer_policy_update_stock_queue.json
}

data "aws_iam_policy_document" "producer_policy_update_stock_queue" {
  statement {
    actions = [
      "sqs:GetQueueAttributes",
      "sqs:GetQueueUrl",
      "sqs:SendMessage",
      "sqs:SendMessageBatch"
    ]
    resources = [
      aws_sqs_queue.update_stock_queue.arn
    ]
  }
}
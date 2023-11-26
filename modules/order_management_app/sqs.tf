resource "aws_sqs_queue" "process_order_queue" {
  name                      = "process_order_queue"
  delay_seconds             = 10
  max_message_size          = 2048
  message_retention_seconds = 86400
  receive_wait_time_seconds = 10
  redrive_policy            = "{\"deadLetterTargetArn\":\"${aws_sqs_queue.process_order_deadletter_queue.arn}\",\"maxReceiveCount\":4}"

}
resource "aws_sqs_queue" "process_order_deadletter_queue" {
  name                       = "process_order_DLQ"
  message_retention_seconds  = 86400
  visibility_timeout_seconds = 60
}

resource "aws_sqs_queue" "update_stock_queue" {
  name                      = "update_stock_queue"
  delay_seconds             = 10
  max_message_size          = 2048
  message_retention_seconds = 86400
  receive_wait_time_seconds = 10
  redrive_policy            = "{\"deadLetterTargetArn\":\"${aws_sqs_queue.update_stock_deadletter_queue.arn}\",\"maxReceiveCount\":4}"

}
resource "aws_sqs_queue" "update_stock_deadletter_queue" {
  name                       = "update_stock_DLQ"
  message_retention_seconds  = 86400
  visibility_timeout_seconds = 60
}
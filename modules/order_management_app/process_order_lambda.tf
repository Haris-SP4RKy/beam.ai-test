


# Create an IAM role for the Lambda function
resource "aws_iam_role" "process_order_lambda_execution_role" {
  name = "process_order_lambda_execution_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}


resource "aws_iam_role_policy_attachment" "lambda_secret_rds_policy1" {
  policy_arn = aws_iam_policy.lambda_rds_secrets_policy.arn
  role       = aws_iam_role.process_order_lambda_execution_role.name
}
resource "aws_iam_role_policy_attachment" "consume_process_order_queue_policy" {
  policy_arn = aws_iam_policy.consumer_policy_process_order_queue.arn
  role       = aws_iam_role.process_order_lambda_execution_role.name
}
resource "aws_iam_role_policy_attachment" "produce_update_stock_queue_policy" {
  policy_arn = aws_iam_policy.producer_policy_update_stock_queue.arn
  role       = aws_iam_role.process_order_lambda_execution_role.name
}
resource "aws_iam_role_policy_attachment" "process_order_function_logging_policy_attachment" {
  role = aws_iam_role.process_order_lambda_execution_role.name
  policy_arn = aws_iam_policy.get_function_logging_policy.arn
}
# Create the Lambda function
resource "aws_lambda_function" "process_order_lambda" {
  function_name    = "process_order-lambda"
  runtime          = "nodejs14.x"
  handler          = "index.handler"
  filename         = "${path.module}/lambdas/processOrderFunction.zip"
  source_code_hash = filebase64sha256("${path.module}/lambdas/processOrderFunction.zip")
  role             = aws_iam_role.process_order_lambda_execution_role.arn
  environment {
    variables = {
      SQS_QUEUE_URL = aws_sqs_queue.update_stock_queue.id
    }
  }

}

# Create a Lambda permission for Invoke by SQS
resource "aws_lambda_permission" "sqs_invoke_permission_process_order" {
  statement_id  = "AllowExecutionFromSQS"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.process_order_lambda.function_name
  principal     = "sqs.amazonaws.com"
  source_arn    = aws_sqs_queue.process_order_queue.arn
}
resource "aws_lambda_event_source_mapping" "process_order_lambda_sqs_trigger" {
  event_source_arn = aws_sqs_queue.process_order_queue.arn
  function_name    = aws_lambda_function.process_order_lambda.arn
  depends_on       = [aws_sqs_queue.process_order_queue]

}
# CLOUD WATCH INTEGRATION
resource "aws_cloudwatch_log_group" "process_order_lambda_log_group" {
  name              = "/aws/lambda/${aws_lambda_function.process_order_lambda.function_name}"
  retention_in_days = 7
  lifecycle {
    prevent_destroy = false
  }
}
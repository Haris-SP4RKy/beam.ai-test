

# Create an IAM role for the Lambda function
resource "aws_iam_role" "creat_order_lambda_execution_role" {
  name = "creat_order_lambda_execution_role"

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

# Attach a policy to the IAM role to allow Lambda to send messages to the SQS queue
# "arn:aws:iam::aws:policy/service-role/AWSLambdaSQSQueueExecutionRole"
resource "aws_iam_role_policy_attachment" "lambda_sqs_policy" {
  policy_arn = aws_iam_policy.producer_policy_process_order_queue.arn
  role       = aws_iam_role.creat_order_lambda_execution_role.name
}
resource "aws_iam_role_policy_attachment" "create_function_logging_policy_attachment" {
  role = aws_iam_role.creat_order_lambda_execution_role.name
  policy_arn = aws_iam_policy.get_function_logging_policy.arn
}
# Create the Lambda function
resource "aws_lambda_function" "create_order_lambda" {
  function_name    = "create_order-lambda"
  runtime          = "nodejs14.x"
  handler          = "index.handler"
  filename         = "${path.module}/lambdas/createOrderFunction.zip"
  source_code_hash = filebase64sha256("${path.module}/lambdas/createOrderFunction.zip")
  role             = aws_iam_role.creat_order_lambda_execution_role.arn

  environment {
    variables = {
      SQS_QUEUE_URL = aws_sqs_queue.process_order_queue.id
    }
  }
}

resource "aws_lambda_permission" "order_lambda_permission" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.create_order_lambda.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_api_gateway_rest_api.order_api.execution_arn}/*/${aws_api_gateway_method.order_method.http_method}/order"
}


# CLOUD WATCH INTEGRATION
resource "aws_cloudwatch_log_group" "create_order_lambda_log_group" {
  name              = "/aws/lambda/${aws_lambda_function.create_order_lambda.function_name}"
  retention_in_days = 7
  lifecycle {
    prevent_destroy = false
  }
}
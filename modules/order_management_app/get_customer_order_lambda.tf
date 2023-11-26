# Create an IAM policy for Lambda access to RDS and Secrets Manager
resource "aws_iam_policy" "lambda_rds_secrets_policy" {
  name        = "lambda_rds_secrets_policy"
  description = "IAM policy for Lambda to access RDS and Secrets Manager"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "secretsmanager:GetSecretValue",
        "secretsmanager:ListSecrets"
      ],
      "Resource": "${aws_secretsmanager_secret.db_secrets.arn}"
    },
    {
      "Effect": "Allow",
      "Action": [
        "rds-db:connect",
        "rds:DescribeDBInstances"
      ],
      "Resource": "${aws_db_instance.rds_instance.arn}"
    }
  ]
}
EOF
}


# Create an IAM role for the Lambda function
resource "aws_iam_role" "get_order_lambda_execution_role" {
  name = "get_order_lambda_execution_role"

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


resource "aws_iam_role_policy_attachment" "lambda_secret_rds_policy" {
  policy_arn = aws_iam_policy.lambda_rds_secrets_policy.arn
  role       = aws_iam_role.get_order_lambda_execution_role.name
}
resource "aws_iam_role_policy_attachment" "function_logging_policy_attachment" {
  role = aws_iam_role.get_order_lambda_execution_role.name
  policy_arn = aws_iam_policy.get_function_logging_policy.arn
}

# Create the Lambda function
resource "aws_lambda_function" "get_order_lambda" {
  function_name    = "get_order-lambda"
  runtime          = "nodejs18.x"
  handler          = "index.handler"
  filename         = "${path.module}/lambdas/getCustomerOrderFunction.zip"
  source_code_hash = filebase64sha256("${path.module}/lambdas/getCustomerOrderFunction.zip")
  role             = aws_iam_role.get_order_lambda_execution_role.arn

}

# Create a Lambda permission for the GET method
resource "aws_lambda_permission" "order_get_lambda_permission" {
  statement_id  = "AllowAPIGatewayInvokeGet"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.get_order_lambda.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_api_gateway_rest_api.order_api.execution_arn}/*/${aws_api_gateway_method.order_get_method.http_method}/order"
}


# CLOUD WATCH INTEGRATION
resource "aws_cloudwatch_log_group" "get_order_log_group" {
  name              = "/aws/lambda/${aws_lambda_function.get_order_lambda.function_name}"
  retention_in_days = 7
  lifecycle {
    prevent_destroy = false
  }
}

resource "aws_iam_policy" "get_function_logging_policy" {
  name   = "function-logging-policy"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        Action : [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Effect : "Allow",
        Resource : "arn:aws:logs:*:*:*"
      }
    ]
  })
}
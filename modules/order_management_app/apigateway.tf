# Create an API Gateway
resource "aws_api_gateway_rest_api" "order_api" {
  name        = "order-api"
  description = "API for Order Lambda"
}

resource "aws_api_gateway_resource" "order_resource" {
  rest_api_id = aws_api_gateway_rest_api.order_api.id
  parent_id   = aws_api_gateway_rest_api.order_api.root_resource_id
  path_part   = "order"
}
# Create a method for POST requests
resource "aws_api_gateway_method" "order_method" {
  rest_api_id   = aws_api_gateway_rest_api.order_api.id
  resource_id   = aws_api_gateway_resource.order_resource.id
  http_method   = "POST"
  authorization = "NONE"
}

# Create an integration for the POST method
resource "aws_api_gateway_integration" "order_integration" {
  rest_api_id             = aws_api_gateway_rest_api.order_api.id
  resource_id             = aws_api_gateway_resource.order_resource.id
  http_method             = aws_api_gateway_method.order_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.create_order_lambda.invoke_arn
}
resource "aws_api_gateway_method_response" "post_proxy" {
  rest_api_id = aws_api_gateway_rest_api.order_api.id
  resource_id = aws_api_gateway_resource.order_resource.id
  http_method = aws_api_gateway_method.order_method.http_method
  status_code = "200"
}
resource "aws_api_gateway_integration_response" "post_proxy" {
  rest_api_id = aws_api_gateway_rest_api.order_api.id
  resource_id = aws_api_gateway_resource.order_resource.id
  http_method = aws_api_gateway_method.order_method.http_method
  status_code = aws_api_gateway_method_response.post_proxy.status_code

  depends_on = [
    aws_api_gateway_method.order_method,
    aws_api_gateway_integration.order_integration
  ]
}
# Create a method for GET requests
resource "aws_api_gateway_method" "order_get_method" {
  rest_api_id   = aws_api_gateway_rest_api.order_api.id
  resource_id   = aws_api_gateway_resource.order_resource.id
  http_method   = "GET"
  authorization = "NONE"
}

# Create an integration for the GET method
resource "aws_api_gateway_integration" "order_get_integration" {
  rest_api_id             = aws_api_gateway_rest_api.order_api.id
  resource_id             = aws_api_gateway_resource.order_resource.id
  http_method             = aws_api_gateway_method.order_get_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.get_order_lambda.invoke_arn
}

resource "aws_api_gateway_deployment" "deployment" {
  depends_on = [
    aws_api_gateway_integration.order_get_integration,
    aws_api_gateway_integration.order_integration, # Add this line
  ]

  rest_api_id = aws_api_gateway_rest_api.order_api.id
  stage_name = "dev"
}

resource "aws_api_gateway_method_response" "get_proxy" {
  rest_api_id = aws_api_gateway_rest_api.order_api.id
  resource_id = aws_api_gateway_resource.order_resource.id
  http_method = aws_api_gateway_method.order_get_method.http_method
  status_code = "200"
}
resource "aws_api_gateway_integration_response" "get_proxy" {
  rest_api_id = aws_api_gateway_rest_api.order_api.id
  resource_id = aws_api_gateway_resource.order_resource.id
  http_method = aws_api_gateway_method.order_get_method.http_method
  status_code = aws_api_gateway_method_response.get_proxy.status_code

  depends_on = [
    aws_api_gateway_method.order_get_method,
    aws_api_gateway_integration.order_get_integration
  ]
}
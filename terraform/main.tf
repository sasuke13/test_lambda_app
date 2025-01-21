terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  
  backend "s3" {
    bucket = "mindbots-test-lambda-bucket"
    key    = "lambda-api/terraform.tfstate"
    region = "us-east-1"
  }
}

provider "aws" {
  region = var.aws_region
}

# Lambda function
resource "aws_lambda_function" "api_lambda" {
  filename         = "../lambda_function.zip"
  function_name    = var.lambda_function_name
  role            = aws_iam_role.lambda_role.arn
  handler         = "src.main.handler"
  runtime         = "python3.11"
  timeout         = 30
  memory_size     = 256
  
  publish = true
  source_code_hash = filebase64sha256("../lambda_function.zip")

  lifecycle {
    create_before_destroy = true
  }

  layers = [aws_lambda_layer_version.dependencies.arn]
}

# Lambda Layer
resource "aws_lambda_layer_version" "dependencies" {
  filename         = "../lambda_layer.zip"
  layer_name       = "${var.lambda_function_name}-layer"
  compatible_runtimes = ["python3.11"]
}

# API Gateway
resource "aws_apigatewayv2_api" "lambda_api" {
  name          = "${var.lambda_function_name}-api"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_stage" "lambda_stage" {
  api_id = aws_apigatewayv2_api.lambda_api.id
  name   = "$default"
  auto_deploy = true

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_gw.arn
    format = jsonencode({
      requestId      = "$context.requestId"
      ip            = "$context.identity.sourceIp"
      requestTime   = "$context.requestTime"
      httpMethod    = "$context.httpMethod"
      routeKey      = "$context.routeKey"
      status        = "$context.status"
      protocol      = "$context.protocol"
      responseLength = "$context.responseLength"
      path          = "$context.path"
      integration   = {
        error       = "$context.integration.error"
        status      = "$context.integration.status"
        latency     = "$context.integration.latency"
      }
    })
  }
}

resource "aws_apigatewayv2_integration" "lambda_integration" {
  api_id = aws_apigatewayv2_api.lambda_api.id
  integration_type = "AWS_PROXY"
  integration_method = "POST"
  integration_uri = aws_lambda_function.api_lambda.invoke_arn
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "lambda_route" {
  api_id = aws_apigatewayv2_api.lambda_api.id
  route_key = "ANY /{proxy+}"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

# Lambda permissions for API Gateway
resource "aws_lambda_permission" "api_gw" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.api_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.lambda_api.execution_arn}/*/*"
}

# CloudWatch Log Group for API Gateway
resource "aws_cloudwatch_log_group" "api_gw" {
  name              = "/aws/api-gw/${aws_apigatewayv2_api.lambda_api.name}"
  retention_in_days = 30
}

# Deploy using Serverless Framework
resource "null_resource" "serverless_deploy" {
  triggers = {
    always_run = timestamp()
  }

  provisioner "local-exec" {
    command = "serverless deploy --stage ${var.environment}"
  }
}

# Other AWS resources managed by Terraform
resource "aws_cloudwatch_log_group" "api_logs" {
  name              = "/aws/lambda/${data.aws_lambda_function.api.function_name}"
  retention_in_days = 30
} 
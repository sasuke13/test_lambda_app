data "aws_lambda_function" "api" {
  function_name = "fastapi-lambda-${var.environment}"
  depends_on    = [null_resource.serverless_deploy]
} 
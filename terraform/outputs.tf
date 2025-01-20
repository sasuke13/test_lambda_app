output "api_gateway_url" {
  description = "API Gateway URL"
  value       = "${aws_apigatewayv2_api.lambda_api.api_endpoint}/"
}

output "lambda_function_name" {
  description = "Lambda function name"
  value       = aws_lambda_function.api_lambda.function_name
}

output "lambda_function_arn" {
  description = "Lambda function ARN"
  value       = aws_lambda_function.api_lambda.arn
}

output "cloudwatch_log_groups" {
  description = "CloudWatch Log Group names"
  value = {
    api_gateway = aws_cloudwatch_log_group.api_gw.name
    lambda      = "/aws/lambda/${aws_lambda_function.api_lambda.function_name}"
  }
} 
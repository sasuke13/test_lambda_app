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
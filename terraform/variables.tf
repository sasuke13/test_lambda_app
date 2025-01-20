variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "lambda_function_name" {
  description = "Name of the Lambda function"
  type        = string
  default     = "test-lambda-function"
}

variable "terraform_state_bucket" {
  description = "Name of the S3 bucket for Terraform state"
  type        = string
  default     = "mindbots-test-lambda-bucket"
} 
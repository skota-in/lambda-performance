output "lambda_function_arns" {
  value = [aws_lambda_function.nodejs_lambda.arn, aws_lambda_function.llrt_lambda.arn]
}
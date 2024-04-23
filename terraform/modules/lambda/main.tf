# Archive the lambda function
data "archive_file" "lambda_function_zip" {
  type        = "zip"
  source_dir  = "../lambda-functions/${var.lambda_function_name}"
  output_path = "../output/${var.lambda_function_name}.zip"
}

# Create the Lambda function using NodeJS runtime
resource "aws_lambda_function" "nodejs_lambda" {
  function_name    = "${var.lambda_function_name}-nodejs"
  role             = var.lambda_role_arn
  handler          = "index.handler"
  source_code_hash = data.archive_file.lambda_function_zip.output_base64sha256
  filename         = data.archive_file.lambda_function_zip.output_path
  runtime          = "nodejs20.x"
  timeout          = 10
  publish          = true
}

# Create the hello-world Lambda function using LLRT
resource "aws_lambda_function" "llrt_lambda" {
  function_name    = "${var.lambda_function_name}-llrt"
  role             = var.lambda_role_arn
  handler          = "index.handler"
  source_code_hash = data.archive_file.lambda_function_zip.output_base64sha256
  filename         = data.archive_file.lambda_function_zip.output_path
  runtime          = "provided.al2023"
  publish          = true

  layers = [var.lambda_layer_arn]
}

resource "aws_lambda_function_url" "nodejs_url" {
  function_name      = aws_lambda_function.nodejs_lambda.function_name
  authorization_type = "NONE"
}

resource "aws_lambda_function_url" "llrt_url" {
  function_name      = aws_lambda_function.llrt_lambda.function_name
  authorization_type = "NONE"
}

resource "aws_lambda_alias" "nodejs_alias" {
  name             = "latest"
  description      = "Using NodeJS runtime"
  function_name    = aws_lambda_function.nodejs_lambda.arn
  function_version = "$LATEST"
}

resource "aws_lambda_alias" "llrt_alias" {
  name             = "latest"
  description      = "Using LLRT runtime"
  function_name    = aws_lambda_function.llrt_lambda.arn
  function_version = "$LATEST"
}

resource "aws_lambda_function_url" "nodejs_alias_url" {
  function_name      = aws_lambda_function.nodejs_lambda.function_name
  qualifier          = "latest"
  authorization_type = "NONE"
  depends_on         = [aws_lambda_alias.nodejs_alias]
}

resource "aws_lambda_function_url" "llrt_alias_url" {
  function_name      = aws_lambda_function.llrt_lambda.function_name
  qualifier          = "latest"
  authorization_type = "NONE"
  depends_on         = [aws_lambda_alias.llrt_alias]
}
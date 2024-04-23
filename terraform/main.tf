locals {
  lambda_functions = ["hello-world", "list-countries", "list-users"]
}

# Create the custom runtime Lambda layer
resource "aws_lambda_layer_version" "llrt-lambda-x64" {
  filename                 = "../libs/llrt-lambda-x64.zip"
  layer_name               = "llrt-lambda-x64"
  source_code_hash         = filebase64sha256("../libs/llrt-lambda-x64.zip")
  compatible_runtimes      = ["provided.al2023"]
  compatible_architectures = ["x86_64"]
}

# Create IAM role and policy for lambda
resource "aws_iam_role" "iam_for_lambda" {
  name = "lambda_exec_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda_exec_role_policy_attachment" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Create Lambdas
module "lambda" {
  source               = "./modules/lambda"
  for_each             = toset(local.lambda_functions)
  lambda_function_name = each.key
  lambda_layer_arn     = aws_lambda_layer_version.llrt-lambda-x64.arn
  lambda_role_arn      = aws_iam_role.iam_for_lambda.arn
}
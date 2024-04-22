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
data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "iam_for_lambda" {
  name               = "iam_for_lambda"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

# Create Lambdas
module "lambda" {
  source               = "./modules/lambda"
  for_each             = toset(local.lambda_functions)
  lambda_function_name = each.key
  lambda_layer_arn     = aws_lambda_layer_version.llrt-lambda-x64.arn
  lambda_role_arn      = aws_iam_role.iam_for_lambda.arn
}
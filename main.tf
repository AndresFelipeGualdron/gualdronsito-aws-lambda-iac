
# API Gateway
resource "aws_api_gateway_rest_api" "api" {
  name = var.api_name
}

resource "aws_api_gateway_resource" "resource" {
  path_part   = var.resource_integration
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  rest_api_id = aws_api_gateway_rest_api.api.id
}

resource "aws_api_gateway_method" "method" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.resource.id
  http_method   = var.http_method_integration
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "integration" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.resource.id
  http_method             = aws_api_gateway_method.method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.lambda.invoke_arn
}

# Lambda
resource "aws_lambda_permission" "apigw_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "arn:aws:execute-api:${var.myregion}:${var.accountId}:${aws_api_gateway_rest_api.api.id}/*/${aws_api_gateway_method.method.http_method}${aws_api_gateway_resource.resource.path}"
}

resource "aws_lambda_function" "lambda" {
  filename = var.filename_lambda
  function_name = var.lambda_name
  role          = aws_iam_role.role.arn
  handler       = var.lambda_handler
  runtime       = var.lambda_runtime

  source_code_hash = var.source_code_hash_lambda

  depends_on = [
    aws_iam_role_policy_attachment.lambda_logs,
    aws_cloudwatch_log_group.andrea-app-send-friend-request,
  ]
}

# IAM
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

resource "aws_iam_role" "role" {
  name               = var.name_role
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_api_gateway_deployment" "andrea-app-api-deployment" {
  rest_api_id = aws_api_gateway_rest_api.api.id
}

resource "aws_api_gateway_stage" "andrea-app-api-prod-stage" {
  deployment_id = aws_api_gateway_deployment.andrea-app-api-deployment.id
  rest_api_id = aws_api_gateway_rest_api.api.id
  stage_name = "prod"
}

resource "aws_cloudwatch_log_group" "andrea-app-send-friend-request" {
  name = "/aws/lambda/${var.lambda_name}"
  retention_in_days = 1
}

resource "aws_iam_policy" "lambda_logging" {
  name        = "lambda_logging_${var.lambda_name}"
  path        = "/"
  description = "IAM policy for logging from a lambda"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:*:*:*",
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role = aws_iam_role.role.name
  policy_arn = aws_iam_policy.lambda_logging.arn
}

resource "aws_cloudwatch_log_group" "api_gateway_logging" {
  name = "api_gateway_logging_${var.lambda_name}"
  retention_in_days = 1
}

resource "aws_cloudwatch_log_subscription_filter" "andrea_app_cloudwaatch_subscription" {
  name = "filter_${var.lambda_name}"
  pattern = "$.level = 'ERROR'"
  log_group_name = aws_cloudwatch_log_group.api_gateway_logging.name
  destination_arn = aws_api_gateway_rest_api.api.arn
}
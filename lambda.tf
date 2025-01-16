resource "aws_lambda_function" "Ec2-Right-Size-lambda" {

  filename         = "${path.module}/src/lambda_function.zip"
  function_name    = var.lambda_function_name
  role             = aws_iam_role.lambda_role.arn
  handler          = "lambda_function.lambda_handler"
  source_code_hash = data.archive_file.lambda.output_base64sha256
  runtime          = "python3.9"
  timeout          = 30

  environment {
    variables = {
      sns_topic_arn = aws_sns_topic.Ec2-Right-Sizing-SNS.arn
    }
  }

  tags = var.tags

}

data "archive_file" "lambda" {
  type        = "zip"
  source_dir  = "${path.module}/src"
  output_path = "${path.module}/src/lambda_function.zip"
}
data "aws_iam_policy_document" "assume_role_lambda" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy_document" "policy" {
  statement {
    effect = "Allow"
    actions = [
      "ec2:*",
      "SNS:Publish",
      "CloudWatch:List"
    ]
    resources = ["*"]
    /*
    condition {
      test     = "ArnLike"
      variable = "aws:SourceArn"
      values = [
        "arn:aws:lambda:${var.region}:${var.account_id}:function:${var.lambda_function_name}"
      ]
    }*/
  }
}


data "aws_iam_policy_document" "assume_role_event_bridge" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["scheduler.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy_document" "event_bridge_policy" {
  statement {
    effect = "Allow"
    actions = ["lambda:InvokeFunction"]
    resources = ["*"]
  }
}



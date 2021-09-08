data "archive_file" "lambdazip" {
  type        = "zip"
  output_path = "${path.module}/artifacts/alb_check.zip"

  source_dir = "${path.module}/artifacts/lambda/"
}


module "alb_check" {
  source = "./modules/lambda"

  name          = "alb-check"
  description   = "switches ALB TG to standby in case of unhealthy TG"
  artifact_file = "${path.module}/artifacts/alb_check.zip"
  handler       = "alb_check.lambda_handler"
  runtime       = "python3.8"
  memory_size   = 128
  timeout       = 30
  environment = {
    "ALB_TG_ARN"            = aws_lb_target_group.alb_tg.arn
    "ALB_TG_HOTSTANDBY_ARN" = aws_lb_target_group.alb_tg_hotstandby.arn
    "ALB_LISTENER443_ARN"   = module.alb.listener_443_arn
  }
  tags = local.tags
}


# Required policies for the alb_check Function
resource "aws_iam_role_policy" "alb_check_policy" {
  name   = "alb_check_policy"
  role   = module.alb_check.exec_role_id
  policy = data.aws_iam_policy_document.alb_check_policy.json
}

# CloudWatch Event resources
resource "aws_cloudwatch_event_rule" "alb_check_trigger" {
  name                = "alb_checkTrigger"
  schedule_expression = "rate(5 minutes)"
}

resource "aws_cloudwatch_event_target" "alb_check" {
  arn  = module.alb_check.arn
  rule = aws_cloudwatch_event_rule.alb_check_trigger.name
}

resource "aws_lambda_permission" "alb_check" {
  statement_id  = "alb_checkAllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = module.alb_check.arn
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.alb_check_trigger.arn
}

data "aws_iam_policy_document" "alb_check_policy" {
  statement {
    sid    = "ALBmodify"
    effect = "Allow"
    actions = [
      "elasticloadbalancing:ModifyListener",
    ]
    resources = [module.alb.listener_443_arn]
  }
  statement {
    sid    = "ALBCheck"
    effect = "Allow"
    actions = [
      "elasticloadbalancing:DescribeTargetHealth"
    ]
    resources = [
      "*"
    ]
  }
}

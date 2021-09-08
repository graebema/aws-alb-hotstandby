resource "aws_cloudwatch_metric_alarm" "ec2_status_check" {
  alarm_name          = "EC2 status check ${var.name}"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  alarm_description   = "status check of EC2 instance"
  evaluation_periods  = "1"
  metric_name         = "StatusCheckFailed"
  datapoints_to_alarm = "1"
  namespace           = "AWS/EC2"
  period              = "300"
  statistic           = "Average"
  threshold           = "0.99"
  dimensions = {
    InstanceId = aws_instance.ec2.id
  }
  alarm_actions = var.cw_sns_topic_arn != null ? [var.cw_sns_topic_arn] : []
}

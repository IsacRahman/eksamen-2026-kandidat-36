resource "aws_cloudwatch_dashboard" "wishifai" {
  dashboard_name = "Wishifai-${var.candidate_number}"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6
        properties = {
          title  = "Completed Wishifai Analyses"
          region = var.aws_region
          metrics = [
            ["Wishifai", "wishifai.analyses.completed"]
          ]
          period = 60
          stat   = "Sum"
          view   = "timeSeries"
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 0
        width  = 12
        height = 6
        properties = {
          title  = "Rekognition Response Time"
          region = var.aws_region
          metrics = [
            ["Wishifai", "wishifai.rekognition.duration", { stat = "Average" }]
          ]
          period = 60
          view   = "timeSeries"
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 6
        width  = 12
        height = 6
        properties = {
          title  = "Bedrock Response Time"
          region = var.aws_region
          metrics = [
            ["Wishifai", "wishifai.bedrock.duration", { stat = "Average" }]
          ]
          period = 60
          view   = "timeSeries"
        }
      },
    ]
  })
}

resource "aws_cloudwatch_metric_alarm" "wishifai_analyses" {
  alarm_name          = "Wishifai-${var.candidate_number}-high-analysis-volume"
  alarm_description   = "Triggers when more than 100 Wishifai analyses are completed in one minute."
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "wishifai.analyses.completed"
  namespace           = "Wishifai"
  period              = 60
  statistic           = "Sum"
  threshold           = 100
  treat_missing_data  = "notBreaching"
}

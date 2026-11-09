
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
            ["Wishifai", "wishifai.analyses.completed.count"]
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
            ["Wishifai", "wishifai.rekognition.duration.avg"]
          ]
          period = 60
          stat   = "Average"
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
            ["Wishifai", "wishifai.bedrock.duration.avg"]
          ]
          period = 60
          stat   = "Average"
          view   = "timeSeries"
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 6
        width  = 12
        height = 6
        properties = {
          title  = "ECS CPU Utilization"
          region = var.aws_region
          metrics = [
            ["AWS/ECS", "CPUUtilization", "ServiceName", "wishifai-36", "ClusterName", "default"]
          ]
          period = 60
          stat   = "Average"
          view   = "timeSeries"
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 12
        width  = 12
        height = 6
        properties = {
          title  = "ECS Memory Utilization"
          region = var.aws_region
          metrics = [
            ["AWS/ECS", "MemoryUtilization", "ServiceName", "wishifai-36", "ClusterName", "default"]
          ]
          period = 60
          stat   = "Average"
          view   = "timeSeries"
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 12
        width  = 12
        height = 6
        properties = {
          title  = "ECS Running Tasks"
          region = var.aws_region
          metrics = [
            ["AWS/ECS", "LiveTaskCount", "ServiceName", "wishifai-36", "ClusterName", "default"]
          ]
          period = 60
          stat   = "Average"
          view   = "timeSeries"
        }
      }
    ]
  })
}

resource "aws_cloudwatch_metric_alarm" "wishifai_analyses" {
  alarm_name          = "Wishifai-${var.candidate_number}-high-analysis-volume"
  alarm_description   = "Triggers when more than 100 Wishifai analyses are completed in one minute."
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "wishifai.analyses.completed.count"
  namespace           = "Wishifai"
  period              = 60
  statistic           = "Sum"
  threshold           = 100
  treat_missing_data  = "notBreaching"
}

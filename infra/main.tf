data "aws_caller_identity" "current" {}

locals {
  bucket_name = "wishifai-kandidat-${var.candidate_number}-${data.aws_caller_identity.current.account_id}"
}

resource "aws_s3_bucket" "uploads" {
  bucket = local.bucket_name

  tags = {
    Name      = "Wishifai uploads"
    Candidate = var.candidate_number
  }
}

resource "aws_s3_bucket_public_access_block" "uploads" {
  bucket = aws_s3_bucket.uploads.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_iam_role" "task_role" {
  name = "wishifai-task-role-${var.candidate_number}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "task_permissions" {
  name = "wishifai-task-permissions"
  role = aws_iam_role.task_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ]
        Resource = "${aws_s3_bucket.uploads.arn}/*"
      },
      {
        Effect = "Allow"
        Action = [
          "rekognition:DetectLabels"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "bedrock:InvokeModel",
          "bedrock:InvokeModelWithResponseStream"
        ]
        Resource = [
          "arn:aws:bedrock:eu-north-1:244530008913:inference-profile/eu.anthropic.claude-sonnet-4-5-20250929-v1:0",
          "arn:aws:bedrock:*::foundation-model/anthropic.claude-sonnet-4-5-20250929-v1:0"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "cloudwatch:PutMetricData"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_cloudwatch_log_group" "app" {
  name              = "/ecs/wishifai-${var.candidate_number}"
  retention_in_days = 7
}

resource "aws_ecs_express_gateway_service" "app" {
  service_name            = "wishifai-${var.candidate_number}"
  execution_role_arn      = "arn:aws:iam::244530008913:role/ecsTaskExecutionRole"
  infrastructure_role_arn = "arn:aws:iam::244530008913:role/service-role/ecsInfrastructureRoleForExpressServices"
  task_role_arn           = aws_iam_role.task_role.arn

  cpu                   = "1024"
  memory                = "2048"
  health_check_path     = "/actuator/health"
  wait_for_steady_state = true

  primary_container {
    image          = "244530008913.dkr.ecr.${var.aws_region}.amazonaws.com/wishifai-kandidat-${var.candidate_number}:${var.image_tag}"
    container_port = 8080

    aws_logs_configuration {
      log_group         = aws_cloudwatch_log_group.app.name
      log_stream_prefix = "wishifai"
    }

    environment {
      name  = "AWS_REGION"
      value = var.aws_region
    }

    environment {
      name  = "S3_BUCKET"
      value = aws_s3_bucket.uploads.bucket
    }

    environment {
      name  = "BEDROCK_MODEL_ID"
      value = "eu.anthropic.claude-sonnet-4-5-20250929-v1:0"
    }
  }

  depends_on = [
    aws_iam_role_policy.task_permissions
  ]

  tags = {
    Candidate = var.candidate_number
    Project   = "Wishifai"
  }
}

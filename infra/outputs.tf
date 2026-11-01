output "service_url" {
  description = "Public URL of the Wishifai ECS Express service"
  value       = one(aws_ecs_express_gateway_service.app.ingress_paths).endpoint
}

output "s3_bucket_name" {
  description = "S3 bucket used for uploaded images"
  value       = aws_s3_bucket.uploads.bucket
}

output "task_role_arn" {
  description = "IAM task role used by the application"
  value       = aws_iam_role.task_role.arn
}

variable "aws_region" {
  description = "AWS region for application resources"
  type        = string
  default     = "eu-north-1"
}

variable "candidate_number" {
  description = "Exam candidate number"
  type        = string
  default     = "36"
}

variable "image_tag" {
  description = "Docker image tag to deploy"
  type        = string
  default     = "latest"
}

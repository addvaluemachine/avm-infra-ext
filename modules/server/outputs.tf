output "target_group_id" {
  description = "ID that identifies the ALB target group"
  value       = aws_alb_target_group.this.id
}

output "target_group_arn" {
  description = "ARN that identifies the ALB target group"
  value       = aws_alb_target_group.this.arn
}

output "ecr_repository_url" {
  description = "The ECR repository URL"
  value       = module.ecr.repository_url
}

variable "region" {
  description = "AWS region used to provision resources (i.e. us-east-1/us-west-1)"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment used for creating resources (will be appended to various resources)"
  type        = string
  default     = "prod"
}

variable "domain_name" {
  description = "The root domain name"
  type        = string
  default     = "avm.technology"
}

variable "ecr_repository_image" {
  description = "The ECR repository URI for the server image"
  type        = string
  default     = "309847704252.dkr.ecr.us-east-1.amazonaws.com/dev-avm-server:1.0.0"
}

variable "rds_master_username" {
  type        = string
  description = "The master username for the RDS instance"
  default     = "postgres"
}

variable "rds_master_password" {
  type        = string
  description = "The master password for the RDS instance"
  default     = ""
}

variable "rds_database_name" {
  type        = string
  description = "The database name for the RDS instance"
  default     = "avmserver"
}

variable "rds_port" {
  type        = number
  description = "The RDS instance port"
  default     = 5432
}

variable "rds_cpu_usage_threshold" {
  description = "The maximum percentage of CPU utilization."
  type        = number
  default     = 80
}

variable "rds_freeable_memory_threshold" {
  description = "The minimum amount of available random access memory in Byte."
  type        = number
  default     = 64000000 # 64 Megabyte in Byte
}

variable "rds_disk_queue_depth_threshold" {
  description = "The maximum number of outstanding IOs (read/write requests) waiting to access the disk."
  type        = number
  default     = 64
}

variable "workspace_iam_roles" {
  default = {
    mcro                 = "arn:aws:iam::670255240370:role/AVMAdminRole"
    renaissance          = "arn:aws:iam::624134621134:role/AVMAdminRole"
    gap                  = "arn:aws:iam::106421789552:role/AVMAdminRole"
    addvaluemachine-demo = "arn:aws:iam::725002219993:role/AVMAdminRole"
    addvaluemachine      = "arn:aws:iam::902610975495:role/AVMAdminRole"
  }
}

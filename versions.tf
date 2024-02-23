terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.8"
    }
  }

  backend "s3" {
    bucket = "tfstate_bucket_name"
    key    = "terraform/terraform.tfstate"
    region = "bucket_region"
  }
}

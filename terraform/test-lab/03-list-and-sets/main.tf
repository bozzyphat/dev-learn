terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}


# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}

resource "aws_iam_user" "test_create_iam_user" {
    count = length(var.create_iam_user)
    name = var.create_iam_user[count.index]
  
}
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

  variable "create_iam_user" {
    type = string
    #default = "my_iam_user"
  }

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}

resource "aws_iam_user" "my_iam_user" {
  count = 2
  name  = "${var.create_iam_user}_${count.index}"
}
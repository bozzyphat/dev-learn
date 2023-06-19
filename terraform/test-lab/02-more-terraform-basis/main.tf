terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

variable "user_iam_create" {
  type    = string
  default = "my_iam_user"

}
# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}

resource "aws_iam_user" "my_iam_user" {
  count = 2
  name  = "${var.user_iam_create}_${count.index}"
}
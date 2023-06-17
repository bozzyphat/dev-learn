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


#resource type will create
# resource "aws_s3_bucket" "my_s3_bucket" {
#   bucket = "my-phat-test-bucket-001"
# }

# output "region_of_created_bucket" {
#   value = aws_s3_bucket.my_s3_bucket.region
# }

#Create IAM user 1
resource "aws_iam_user" "my_iam_user" {
  name = "my_iam_user_test2"
}



#Create IAM user 2
resource "aws_iam_user" "my_iam_user_2" {
  name = "my_iam_user_test4"
}

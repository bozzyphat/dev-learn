#setoutput
output "new_iam_user_name" {
  value = aws_iam_user.my_iam_user.name
  
}

#setoutput
output "new_iam_user_name_2" {
  value = aws_iam_user.my_iam_user_2.name
  
}
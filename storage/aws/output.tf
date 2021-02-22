output "user_name" {
  value       = join("", aws_iam_user.iam_user_s3.*.name)
  description = "Normalized IAM user name"
}

output "user_arn" {
  value       = join("", aws_iam_user.iam_user_s3.*.arn)
  description = "The ARN assigned by AWS for this user"
}

output "access_key_id" {
  value       = join("", aws_iam_access_key.iam_user_s3_key.*.id)
  description = "The access key ID"
}

output "secret_access_key" {
  #sensitive   = true
  value       = join("", aws_iam_access_key.iam_user_s3_key.*.secret)
  description = "The secret access key. This will be written to the state file in plain-text"
}
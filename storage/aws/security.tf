resource "aws_iam_user" "iam_user_s3" {
  name = "s3-public-full"
  path = "/api/"

  tags = {
    description = "Usuario para el consumo de la api del S3"
  }
}

resource "aws_iam_access_key" "iam_user_s3_key" {
  user = aws_iam_user.iam_user_s3.name
}


resource "aws_iam_user_policy" "iam_user_s3_policy" {
  name = "Myjourney-S3-Public-FullAccess"
  user = aws_iam_user.iam_user_s3.name

  policy = file("./${path.module}/files/s3_policy.json")
}
# ARN : 아마존 리소스 이름
output "s3_bucket_arn" {
  value = "${aws_s3_bucket.terraform_state.arn}"
}
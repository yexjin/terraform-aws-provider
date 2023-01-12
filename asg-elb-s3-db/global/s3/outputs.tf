# 수행 내역을 확인하기 위한 ARN(Amazon Resource Name)
output "s3_bucket_arn" {
  value = "${aws_s3_bucket.terraform_state.arn}"
}
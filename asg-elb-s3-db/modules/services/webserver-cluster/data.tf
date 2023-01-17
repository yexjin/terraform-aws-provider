## aws 가용영역 가져오기 ##
data "aws_availability_zones" "all" {
}

## s3 버킷에 있는 상태 파일의 데이터 읽어오기 ##
data "terraform_remote_state" "db" {
  backend = "s3"

  config = {
    bucket = "${var.db_remote_state_bucket}"
    key = "${var.db_remote_state_key}"
    region = "us-east-1"
  }
}
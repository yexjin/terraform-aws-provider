# aws를 공급자로 지정
provider "aws" {
  region = "us-east-1"
}

terraform {
  backend "s3" {
    bucket = "lena-tfstate-bucket"
    key = "terraform.tfstate"
    region = "us-east-1"
    encrypt = true
  }
}

resource "aws_s3_bucket" "terraform_state" {
  bucket = "lena-tfstate-bucket"

  lifecycle {
    prevent_destroy = true
  }
}

# versioning : 버킷에 있는 파일을 업데이트할 때마다 실제로 해당 파일의 새 버전이 만들어지도록 버저닝
resource "aws_s3_bucket_versioning" "versioning-ex" {
  bucket = aws_s3_bucket.terraform_state.id

  versioning_configuration {
    status = "Enabled"
  }
}


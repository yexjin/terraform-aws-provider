# 인프라를 배포하고자 하는 리전 선언
provider "aws" {
  region = "us-east-1"
}

module "single-server" {
  source = "../modules/"

  instance_type = "t2.micro"
  server_name = "server-stage"
}
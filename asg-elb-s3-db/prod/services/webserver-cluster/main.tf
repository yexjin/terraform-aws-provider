# s3 bucket에 테라폼 상태 저장
terraform {
  backend "s3" {
    bucket = "lena-tf-state-bucket"
    key = "stage/services/webserver-cluster/terraform.tfstate"
    region = "us-east-1"
    encrypt = true
    dynamodb_table = "lena-tf-state-bucket-lock"
  }
}


provider "aws" {
  region = "us-east-1"
}

module "webserver_cluster" {
  source = "../../../modules/services/webserver-cluster"

  cluster_name = "webserver-prod"
  db_remote_state_bucket = "lena-tf-state-bucket"
  db_remote_state_key = "stage/datastores/mysql/terraform.tfstate"

  instance_type = "t2.micro"
  min_size = 2
  max_size = 10
}
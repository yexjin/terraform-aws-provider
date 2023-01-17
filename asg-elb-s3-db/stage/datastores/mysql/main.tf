## DB가 S3에 모든 상태를 저장하도록 원격 상태 저장소를 구성
terraform {
  backend "s3" {
    bucket = "lena-tf-state-bucket"
    key = "stage/datastores/mysql/terraform.tfstate"
    region = "us-east-1"
    encrypt = true
    dynamodb_table = "lena-tf-state-bucket-lock"
  }
}

provider "aws" {
  region = "us-east-1"
}

## 데이터 베이스 리소스 생성 ##
module "mysql" {
  source = "../../../modules/datastores/mysql"
  db_allocated_storage = 10
  db_instance_class = "db.t2.micro"
  db_name = "prod_db"
  db_password = var.db_password
  db_username = "admin"
}
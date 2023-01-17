provider "aws" {
  region = "us-east-1"
}

module "webserver_cluster" {
  source = "../../../modules/services/webserver-cluster"

  cluster_name = "webserver-stage"
  db_remote_state_bucket = "lena-tf-state-bucket"
  db_remote_state_key = "stage/services/webserver-cluster/terraform.tfstate"
}
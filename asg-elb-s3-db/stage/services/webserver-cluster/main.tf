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


## 모듈화 ##
module "webserver_cluster" {
  source = "../../../modules/services/webserver-cluster"

  cluster_name = "webserver-stage"
  db_remote_state_bucket = "lena-tf-state-bucket"
  db_remote_state_key = "stage/datastores/mysql/terraform.tfstate"

  instance_type = "t2.micro"
  min_size = 2
  max_size = 2
}


## Auto Scaling Schedule ##
resource "aws_autoscaling_schedule" "scale_out_during_business_hours" {
  scheduled_action_name = "scale-out-during-business-hours"
  min_size = 4
  max_size = 10
  desired_capacity = 10
  recurrence = "0 9 * * *"  # 매일 오전 9시
  autoscaling_group_name = "${module.webserver_cluster.asg_name}"
}

resource "aws_autoscaling_schedule" "scale-in-at-night" {
  scheduled_action_name  = "scale-in-at-night"
  min_size               = 4
  max_size               = 10
  desired_capacity       = 4
  recurrence             = "0 17 * * *"  # 매일 오후 5시
  autoscaling_group_name = "${module.webserver_cluster.asg_name}"
}


## 추가 포트 열기 ##
resource "aws_security_group_rule" "allow_testing_inbound" {
  type              = "ingress"
  security_group_id = "${module.webserver_cluster.elb_security_group_id}"

  from_port         = 12345
  protocol          = "tcp"
  to_port           = 12345
  cidr_blocks = ["0.0.0.0/0"]
}
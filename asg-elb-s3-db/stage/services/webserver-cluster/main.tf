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

## EC2 인스턴스를 ASG에 설정하는 시작 구성 ##
resource "aws_launch_configuration" "example"{
  image_id = "ami-40d28157"
  instance_type = "t2.micro"
  security_groups = ["${aws_security_group.elb.id}"]

  # EC2 인스턴스에 포트 번호를 설정하는 비지박스 부분
  # - EC2 인스턴스의 사용자 데이터 설정을 통해 "Hello, World" 스크립트를 인스턴스 기동시 수행할 수 있게 된다.
  user_data = <<-EOF
#!/bin/bash
echo "Hello, World" >> index.html
echo "${data.terraform_remote_state.db.outputs.address}" >> index.html
echo "${data.terraform_remote_state.db.outputs.port}" >> index.html
nohup busybox httpd -f -p "${var.server_port}" &
EOF

  lifecycle {
    create_before_destroy = true
  }

}

## 보안 그룹 설정 ##
resource "aws_security_group" "elb" {
  name = "terraform-elb-instance"

  # 포트 80번 트래픽을 확인한 후, 연동
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # 인터넷이 연결된 어느곳에서라도 접속
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # 인터넷이 연결된 어느곳에서라도 접속
  }

  # 상태체크를 요청하기 위해 내보내는 트래픽 허용
  egress {
    from_port = 0
    protocol  = "-1"
    to_port   = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  # 설정 리소스와 관련된 리소스이기에 create_before_destroy = true
  lifecycle {
    create_before_destroy = true
  }
}

## ASG 생성 ##
resource "aws_autoscaling_group" "example" {
  launch_configuration = "${aws_launch_configuration.example.id}"
  availability_zones = "${data.aws_availability_zones.all.names}"

  load_balancers = ["${aws_elb.example.name}"]  # 인스턴스가 시작할 때 ELB에 각 인스턴스를 등록하도록 ASG에 요청
  health_check_type = "ELB"

  max_size = 10
  min_size = 2

  tag {
    key = "Name"
    value = "terraform-asg-example"
    propagate_at_launch =  true
  }
}

## ELB 생성 ##
resource "aws_elb" "example" {
  name = "terraform-asg-example"
  availability_zones = "${data.aws_availability_zones.all.names}"
  # 기본적으로 들어오고 나가는 트래픽에 대해 허용하지 않게 하기 위해, 보안 그룹에 포트 80번 트래픽에 대해 정의해야 함.
  security_groups = ["${aws_security_group.elb.id}"]

  # 특정 포트에 대한 트래픽을 라우팅 하기 위해 하나 이상의 리스너를 설정
  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = "${var.server_port}"
    lb_protocol       = "http"
  }

  # 상태를 지속적으로 체크하는 elb의 health check 블록
  # 30 초 마다 '/' URL로 HTTP 요청을 하여 ASG에 있는 인스턴스 응답이 '200 OK'인지 확인하는 설정
  health_check {
    healthy_threshold   = 2
    interval            = 30
    target              = "HTTP:${var.server_port}/"
    timeout             = 3
    unhealthy_threshold = 2
  }
}

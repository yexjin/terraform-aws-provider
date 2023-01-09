terraform {
  backend "s3" {
    bucket = "lena-tfstate-bucket"
    key = "stage/services/webserver-cluster/terraform.tfstate"
    region = "us-east-1"
    encrypt = true
    dynamodb_table = "lena-tfstate-bucket-lock"
  }
}

provider "aws" {
  region = "us-east-1"
}

# EC2 인스턴스를 ASG에 설정하는 시작 구성
resource "aws_launch_configuration" "example"{
  image_id = "ami-40d28157"
  instance_type = "t2.micro"
  security_groups = ["${aws_security_group.instance.id}"]

  user_data = <<-EOF
#!/bin/bash
echo "Hello, World" > index.html
nohup busybox httpd -f -p "${var.server_port}" &
EOF

  lifecycle {
    create_before_destroy = true
  }

}

resource "aws_security_group" "instance" {
  name = "terraform-example-instance"

  # cidr 블록으로부터 8080 포트에 대한 tcp 요청을 받아들일 수 있도록
  ingress {
    from_port   = var.server_port
    protocol    = "tcp"
    to_port     = var.server_port
    cidr_blocks = ["0.0.0.0/0"] # 인터넷이 연결된 어느곳에서라도 접속
  }

  lifecycle {
    create_before_destroy = true
  }
}

# ASG 생성
resource aws_autoscaling_group "example" {

  launch_configuration = "${aws_launch_configuration.example.id}"
  availability_zones = "${data.aws_availability_zones.all.names}"

  max_size = 10
  min_size = 2

  tag {

    key                 = "Name"
    propagate_at_launch = true
    value               = "terraform-asg-example"

  }
}

# AWS 모든 가용 AZ 가져오기
data "aws_availability_zones" "all" {

}

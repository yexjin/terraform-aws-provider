provider "aws" {
  region = "us-east-1"
}


## EC2 인스턴스를 ASG에 설정하는 시작 구성 ##
resource "aws_launch_configuration" "example"{
  image_id = "ami-40d28157"
  instance_type = "t2.micro"
  security_groups = ["${aws_security_group.elb.id}"]

  user_data = <<-EOF
#!/bin/bash
echo "Hello, World" > index.html
nohup busybox httpd -f -p "${var.server_port}" &
EOF

  lifecycle {
    create_before_destroy = true
  }

}



## ELB(Elastic LoadBalancer)를 테라폼에서 사용하기 ##
resource "aws_elb" "example" {

  name = "terraform-asg-example"
  availability_zones = "${data.aws_availability_zones.all.names}"
  security_groups = ["${aws_security_group.elb.id}"]

  # 특정 포트에 대한 트래픽을 라우팅 하기 위한 하나 이상의 리스터 설정
  # ELB가 포트 80으로 HTTP응답을 받아 ASG에 있는 웹 서버로 트래픽을 전달하는 설
  listener {
    instance_port     = "${var.server_port}"
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "HTTP"
  }

  # 30 초 마다 '/' URL로 HTTP 요청을 하여 ASG에 있는 인스턴스 응답이 '200 OK'인지 확인하는 설정
  health_check {
    healthy_threshold   = 2
    interval            = 30
    target              = "HTTP:${var.server_port}/"
    timeout             = 3
    unhealthy_threshold = 2
  }
}




resource "aws_security_group" "elb" {
  name = "terraform-example-elb"

  # cidr 블록으로부터 8080 포트에 대한 tcp 요청을 받아들일 수 있도록
  ingress {
    from_port   = 80
    protocol    = "tcp"
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"] # 인터넷이 연결된 어느곳에서라도 접속
  }

  # health_check 요청을 위해 내보내는 트래픽 허용
  egress {

    from_port = 0
    protocol  = "-1"
    to_port   = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = true
  }

}



## ASG 생성 ##
resource aws_autoscaling_group "example" {

  launch_configuration = "${aws_launch_configuration.example.id}"
  availability_zones = "${data.aws_availability_zones.all.names}"

  # load_balancers : 인스턴스가 시작될 때, ELB에 각 인스턴스를 등록
  load_balancers = ["${aws_elb.example.name}"]
  # health_check_type : ASG를 통해 인스턴스가 정상적인지 판단하고 아니라면 다른 인스턴스 교체하도록 요청
  health_check_type = "ELB"

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

variable "server_port" {
  description = "The port the server will use for HTTP requests"
  default = 8080
}

# ELB의 도메인 이름 출력
output "elb_dns_name" {
  value = "${aws_elb.example.dns_name}"
}
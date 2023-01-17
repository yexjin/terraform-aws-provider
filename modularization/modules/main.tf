resource "aws_instance" "example" {
  ami = "ami-40d28157"
  instance_type = "${var.instance_type}"
  vpc_security_group_ids = ["${aws_security_group.instance.id}"]

  user_data = <<-EOF
#!/bin/bash
echo "Hello, World" > index.html
nohup busybox httpd -f -p "${var.server_port}" &
EOF

}

resource "aws_security_group" "instance" {
  name = "${var.server_name}-instance"

  # cidr 블록으로부터 8080 포트에 대한 tcp 요청을 받아들일 수 있도록
  ingress {
    from_port   = var.server_port
    protocol    = "tcp"
    to_port     = var.server_port
    cidr_blocks = ["0.0.0.0/0"] # 인터넷이 연결된 어느곳에서라도 접속
  }
}


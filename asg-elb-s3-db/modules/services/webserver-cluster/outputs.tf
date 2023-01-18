## FOR auto scaling schedule ##
output "asg_name" {
  value = "${aws_autoscaling_group.example.name}"
}

## 클러스터 배포 시, 테스트할 URL ##
output "elb_dns_name" {
  value = "${aws_elb.example.dns_name}"
}

## 추가 포트를 열어야 할 경우 ##
output "elb_security_group_id" {
  value = "${aws_security_group.elb.id}"
}
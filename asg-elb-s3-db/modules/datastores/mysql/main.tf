## 데이터 베이스 리소스 생성 ##
resource "aws_db_instance" "mysql" {
  engine = "mysql"
  allocated_storage = var.db_allocated_storage
  instance_class = var.db_instance_class
  db_name = var.db_name
  username = var.db_username
  password = var.db_password
}
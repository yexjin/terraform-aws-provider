## 필요한 데이터베이스 변수 값을 출력값으로 빼서 state 파일에 저장되도록 출력 변수 설정
output "address" {
  value = module.mysql.address
}

output "port" {
  value = module.mysql.port


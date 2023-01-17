variable "cluster_name" {
  description = "The name to use for all the cluster resources"
}

variable "db_remote_state_bucket" {
  description = "The name to use for S3 bucket for the database's remote state"
}

variable "db_remote_state_key" {
  description = "The path for the database's remote state in S3"
}

variable "instance_type" {
  description = "The type of EC2 Instances to run (e.g. t2.micro)"
}

variable "min_size" {
  description = "The minimum number of EC2 Instances in the ASG"
}

variable "max_size" {
  description = "The maximum number of EC2 Instancees in the ASG"
}



## stage에서 가져온 변수들 ##

variable "server_port" {
  description = "The port the server will use for HTTP requests"
  default = 8080
}

data "aws_availability_zones" "all" {
}


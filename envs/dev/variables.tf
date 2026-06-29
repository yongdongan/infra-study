# envs/dev 에서 사용할 변수 선언
# 실제 값은 terraform.tfvars 파일에서 주입

variable "env" { type = string }
variable "vpc_cidr" { type = string }
variable "public_subnets" { type = list(string) }
variable "private_subnets" { type = list(string) }
variable "azs" { type = list(string) }



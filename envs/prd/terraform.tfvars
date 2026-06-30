#CIDR을 dev(10.0.x.x)와 다르게 설정 -> 나중에 VPC Peering 시 충돌 방지

env             = "prd"
vpc_cidr        = "10.2.0.0/16"
public_subnets  = ["10.2.1.0/24", "10.2.2.0/24"]
private_subnets = ["10.2.11.0/24", "10.2.12.0/24"]
azs             = ["ap-northeast-2a", "ap-northeast-2c"]


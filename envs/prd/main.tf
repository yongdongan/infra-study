# module 블록: modules/vpc 폴더의 코드를 불러와 실행
# source: 모듈 경로 (상대 경로 또는 Terraform Registry URL)

module "vpc" {
  source          = "../../modules/vpc" # envs/dev 기준 상대 경로
  env             = var.env
  vpc_cidr        = var.vpc_cidr
  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets
  azs             = var.azs
}

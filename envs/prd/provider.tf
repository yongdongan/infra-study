terraform {
  # required_providers: 이 프로젝트에서 사용할 프로바이더와 버전 범위 지정
  required_providers {
    aws = {
      source  = "hashicorp/aws" # Terraform 레지스트리에서 hashicorp가 만든 aws 프로바이더
      version = "~> 5.0"        # 5.x 최신 버전 사용 (6.0은 허용 안 함)
    }
  }
}


provider "aws" {
  region = "ap-northeast-2" # 모든 리소스를 서울 리전에 생성
}



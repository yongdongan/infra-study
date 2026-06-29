# terraform.tfvars: variables.tf 에 선언된 변수의 실제 값을 입력하는 파일
# terraform apply 실행 시 자동으로 읽음

env = "dev"

# /16: 10.0.x.x 전체 범위 (65,536개 IP)
# 나중에 변경 불가 -> 처음에 넉넉하게 지정
vpc_cidr = "10.0.0.0/16"

# Public Subnet 2개 - 서로 다른 AZ에 배치 (고가용성)
# /24: 10.0.1.x 범위 (256개 IP)
public_subnets = ["10.0.1.0/24", "10.0.2.0/24"]

# Private Subnet 2개 - 앞자리를 11, 12로 구분해 Public과 겹치지 않게
private_subnets = ["10.0.11.0/24", "10.0.12.0/24"]

# 서울 리전의 가용영역 a, c 두 곳 사용
# ap-northeast-2b 를 건너뛰는 이유: 일부 인스턴스 타입이 b에서 제공 안되는 경우가 있음
azs = ["ap-northeast-2a", "ap-northeast-2c"]


# variable 블록: 모듈 외부에서 값을 주입받을 입력 변수 정의
# 함수의 파라미터와 같은 역할

# env: dev/ stg/ prd 등 환경 이름. 리소스 이름 태그에 사용
variable "env" { type = string }

# vpc_cidr: VPC 전체 IP 범위 (예: "10.0.0.0/16" -> 65.536개 IP)
variable "vpc_cidr" { type = string }

# public_subnets: 공개 서브넷 CIDR 목록 (ALB, NAT Gateway 배치)
variable "public_subnets" { type = list(string) }

# private_subnets: 비공개 서브넷 CIDR 목록 (EKS 노드, RDS 배치)
variable "private_subnets" { type = list(string) }


# azs: 사용할 가용영역 목록 (최소 2개 -> 고가용성)
variable "azs" { type = list(string) }

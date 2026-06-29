# output 블록: 이 모듈을 호출하는 상위 코드에서 참조할 수 있는 출력 값
# 예: module.vpc.vpc_id 로 VPC ID를 다른 모듈에서 사용 가능

# VPC ID: EKS, SG 등 다른 리소스가 "어느 VPC에 속하는지" 지정할 때 사용
output "vpc_id" { value = aws_vpc.this.id }


# Public Subnet ID 목록: ALB, NAT Gateway 배치 시 사용
# [*]: 리스트의 모든 요소를 순서대로 반환 (리스트 스플랫 표현식)
output "public_subnet_ids" { value = aws_subnet.public[*].id }

# Private Subnet ID 목록: EKS 노드그룹, RDS 배치 시 사용
output "private_subnet_ids" { value = aws_subnet.private[*].id }



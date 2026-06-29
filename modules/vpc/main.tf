# VPC: AWS 계정 내 격리된 가상 네트워크 공간
# enable_dns_hostnames: EC2 인스턴스에 DNS 이름 자동 할당 (EKS 필수)
# enable_dns_support: VPC 내부 DNS 해석 활성화 (EKS 필수)

resource "aws_vpc" "this" {
  cidr_block = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support = true
  tags = { Name = "${var.env}-vpc" } # "${var.env}-vpc" -> "dev-vpc"
} 

# Public Subnet: 인터넷과 직접 통신 가능한 서브넷
# count: var.public_subnets 목록 개수만큼 반복 생성
# count.index: 0, 1, 2 ... 순서로 증가하는 인덱스
# map_public_ip_on_launch: 이 서브넷에 생성된 EC2에 공인 IP 자동 할당

resource "aws_subnet" "public" {
  count = length(var.public_subnets)
  vpc_id = aws_vpc.this.id
  cidr_block = var.public_subnets[count.index]
  availability_zone = var.azs[count.index]
  map_public_ip_on_launch = true
  tags = { Name = "${var.env}-public-${count.index + 1}" }
}

# Private Subnet: 인터넷에서 직접 접근 불가한 서브넷
# map_public_ip_on_launch 없음 -> 공인 IP 미할당
resource "aws_subnet" "private" {
  count = length(var.private_subnets)
  vpc_id = aws_vpc.this.id
  cidr_block = var.private_subnets[count.index]
  availability_zone = var.azs[count.index]
  tags = { Name = "${var.env}-private-${count.index + 1}" }
}

# Internet Gateway(IGW): VPC와 인터넷을 연결하는 문
# Public Subnet의 Route Table에 연결되어 인터넷 통신 가능하게 함

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id
  tags = { Name = "${var.env}-igw" }
}

# Elastic IP: Nat Gateway에 부여할 고정 공인 IP
# domain: "vpc": VPC 내에서 사용하는 EIP임을 명시 (최신 방식)
resource "aws_eip" "nat" {
  domain = "vpc"
}

# NAT Gateway: Private Subnet -> 인터넷 단방향 통신 담당
# Private Subnet의 EC2가 패키지를 설치하거나 외부 API를 호출할 때 사용
# 반대 방향(인터넷 -> Private)은 차단
# subnet_id: Nat Gateway는 반드시 Public Subnet에 위치해야 함

resource "aws_nat_gateway" "this" {
  allocation_id = aws_eip.nat.id
  subnet_id = aws_subnet.public[0].id # public 서브넷 첫 번째에 위치
  tags = { Name = "${var.env}-nat" }
}

# Public Route Table: Public Subnet의 트래픽 경로 정의
# 0.0.0.0/0 -> IGW: "모든 목적지 트래픽을 인터넷을 보내라"
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }
  tags = { Name = "${var.env}-public-rt" }
}

# Route Table Association: Public Subnet들을 Public Route Table에 연결
# 이 연결이 없으면 서브넷이 Route Table을 사용하지 않음

resource "aws_route_table_association" "public" {
  count = length(var.public_subnets)
  subnet_id = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# Private Route Table: Private Subnet의 트래픽 경로 정의
# 0.0.0.0/0 -> NAT Gateway: "외부 통신은 NAT를 통해 나가되 들어오는 건 막아라"

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.this.id
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.this.id
  }
  tags = { Name = "${var.env}-private-rt" }
}

# Private Subnet들을 Private Route Table에 연결
resource "aws_route_table_association" "private" {
  count = length(var.private_subnets)
  subnet_id = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}

# EKS 클러스터 (Control Plane)
# version: Kubernetes 버전. EKS는 최신 3개 버전만 지원하므로 최신 버전 사용 권장
# role_arn: Control Plane이 AWS API를 호출할 때 사용할 IAM Role

resource "aws_eks_cluster" "this" {
  name     = "${var.env}-cluster"
  version  = var.cluster_version
  role_arn = aws_iam_role.cluster.arn



  vpc_config {
    # Private Subnet에 Control Plane 엔드포인트 배치 (더 안전)
    subnet_ids = var.private_subnet_ids

    # endpoint_private_access: VPC 내부에서 API Server 접근 허용
    endpoint_private_access = true

    # endpoint_public_access: 인터넷에서 kubectl 실행 허용 (학습 편의상 true)
    # 실무 prd 환경에서는 false 로 설정하고 VPN을 통해 접근
    endpoint_public_access = true
  }


  # depends_on: cluster_policy 연결이 완료된 후에 클러스터 생성 시작
  # IAM 정책이 없으면 클러스터 생성이 실패하므로 순서 보장 필요
  depends_on = [aws_iam_role_policy_attachment.cluster_policy]
}

# On-demand 노드 그룹: 중단 없이 안정적으로 실행되어야 하는 워크로드용
# capacity_type = "ON_DEMAND": 정가 인스턴스 (AWS가 임의로 중단 안 함)
# instance_types: 노드에 사용할 EC2 인스턴스 타입
# scaling_config: 최소/최대/원하는 노드 수 설정

resource "aws_eks_node_group" "ondemand" {
  cluster_name    = aws_eks_cluster.this.name
  node_group_name = "${var.env}-ondemand"
  node_role_arn   = aws_iam_role.node.arn
  subnet_ids      = var.private_subnet_ids # 노드는 Private Subnet에 배치
  instance_types  = ["t3.medium"]
  capacity_type   = "ON_DEMAND"

  scaling_config {
    desired_size = 2 # 현재 유지할 노드
    min_size     = 1 # 최소 노드 수 (이 이하로 줄이지 않음)
    max_size     = 5 # 최대 노드 수 (오토스케일링 상한선)
  }

  # 노드 Role 관련 3개 정책이 모두 연결된 후에 노드그룹 생성
  depends_on = [
    aws_iam_role_policy_attachment.node_worker,
    aws_iam_role_policy_attachment.node_cni,
    aws_iam_role_policy_attachment.node_ecr,
  ]
}

# Spot 노드그룹: 비용 절감용 (On-demand 대비 최대 70% 저렴)
# capacity_type = "SPOT": AWS가 여유 용량 없으면 2분 예고 후 회수 가능
# instance_types: 여러 타입 지정 -> Spot 가용성 높아짐 (한 타입이 없으면 다른 타입 사용)

resource "aws_eks_node_group" "spot" {
  cluster_name    = aws_eks_cluster.this.name
  node_group_name = "${var.env}-spot"
  node_role_arn   = aws_iam_role.node.arn
  subnet_ids      = var.private_subnet_ids
  instance_types  = ["t3.medium", "t3.large", "t3a.medium"] # 여러 타입으로 가용성 확보
  capacity_type   = "SPOT"

  scaling_config {
    desired_size = 1
    min_size     = 0 # 0: 필요 없으면 노드 0개로 줄일 수 있음 (비용 절감)
    max_size     = 10
  }
}

# vpc-cni Add-on: Pod에 VPC IP를 직접 할당하는 네트워크 플러그인
# EKS에서 Pod간 통신을 위해 필수
# resource "aws_eks_addon" "vpc_cni" {
#   cluster_name = aws_eks_cluster.this.name
#   addon_name   = "vpc-cni"
# }

# coredns Add-on: 클러스터 내부 DNS 서버
# Pod가 서비스 이름 (예: my-service.default.svc.cluster.local)으로 통신할 수 있게 함
# 노드가 있어야 CoreDNS Pod를 배치할 수 있으므로 ondemand 노드그룹 이후 생성

resource "aws_eks_addon" "vpc_cni" {
  cluster_name = aws_eks_cluster.this.name
  addon_name   = "vpc-cni"
  depends_on   = [aws_eks_node_group.ondemand]
}

# kube-proxy Add-on: 각 노드에서 네트워크 규칙(iptables)을 관리
# Service  -> Pod 트래픽 라우팅 담당
resource "aws_eks_addon" "kube_proxy" {
  cluster_name = aws_eks_cluster.this.name
  addon_name   = "kube-proxy"
}

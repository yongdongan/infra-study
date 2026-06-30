# Cluster Role: EKS Control Plane 이 AWS API를 호출할 때 사용하는 Role
# assume_role_policy: "누가 이 Role을 사용할 수 있는지" 신뢰 정책
# Service = "eks.amazonaws.com": EKS 서비스가 이 Role을 사용

resource "aws_iam_role" "cluster" {
  name = "${var.env}-eks-cluster-role"

  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "eks.amazonaws.com" }
    }]
  })
}

# AmazonEKSClusterPolicy: EKS Control Plane 운영에 필요한 AWS 관리형 정책
# EC2, ELB, AutoScaling 등 EKS가 내부적으로 호출하는 서비스 권한 포함
resource "aws_iam_role_policy_attachment" "cluster_policy" {
  role = aws_iam_role.cluster.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

# Node Role: Worker Node(EC2)가 사용하는 Role
# Service = "ec2.amazonaws.com": EC2 인스턴스가 이 Role을 사용
resource "aws_iam_role" "node" {
  name = "${var.env}-eks-node-role"


  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })
}

# AmazonEKSWorkerNodePolicy: 노드가 클러스터에 조인하는 데 필요한 기본 권한

resource "aws_iam_role_policy_attachment" "node_worker" {
  role = aws_iam_role.node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

# AmazonEKS_CNI_Policy: 노드가 Pod에 IP를 할당하기 위해 VPC를 제어하는 권한
# CNI (Container Network Interface): Pod 네트워크 관리 컴포넌트

resource "aws_iam_role_policy_attachment" "node_cni" {
  role = aws_iam_role.node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

# AmazonEC2ContainerRegistryReadOnly: ECR에서 컨테이너 이미지를 pull 하는 권한
# ReadOnly: push 권한 없이 읽기만 허용 (보안 원칙: 최소 권한)
resource "aws_iam_role_policy_attachment" "node_ecr" {
  role = aws_iam_role.node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

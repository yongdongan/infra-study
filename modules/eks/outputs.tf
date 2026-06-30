# cluster_name: GitHub Actions, kubectl 설정 등에서 클러스터 이름 참조 시 사용
output "clsuter_name" {
  value = aws_eks_cluster.this.name
}

# cluster_endpoint: kubectl 이 API Server 와통신할 URL
output "cluster_endpoint" {
  value = aws_eks_cluster.this.endpoint
}

# oidc_issuer: Phase 4에서 IRSA(Pod에 IAM Role 부여) 설정 시 필요
output "oidc_issuer" {
  value = aws_eks_cluster.this.identity[0].oidc[0].issuer
}
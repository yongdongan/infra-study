variable "env" { type = string }
# cluster_version: EKS Kubernetes 버전. 기본값 "1.29"

variable "cluster_version" {
  type = string
}

# private_subent_ids: Phase 1 에서 만든 VPC의 Private Subnet ID 목록
variable "private_subnet_ids" { type = list(string) }


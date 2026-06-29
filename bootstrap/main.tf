# AWS 프로바이더 설정: Terraform이 어떤 클라우드를 접속할지 지정
# region: 모든 리소스를 생성할 리전 (ap-northeast-2 = 서울)

provider "aws" {
  region = "ap-northeast-2"
}


# S3 버킷: Terraform State 파일을 저장하는 공간
# bucket 이름은 전 세계에서 유일해야 함 -> 계정 ID를 붙여 고유하게 만듬

resource "aws_s3_bucket" "tfstate" {
  bucket = "infra-study-tfstate-yongdong"
}

# 버전 관리 활성화: State 파일이 엎어쓰여도 이전 버전으로 복구 가능

resource "aws_s3_bucket_versioning" "tfstate" {
  bucket = aws_s3_bucket.tfstate.id # 위에서 만든 버킷의 ID를 참조
  versioning_configuration {
    status = "Enabled" # "Enabled" | "Suspended"
  }
}

# 서버 사이드 암호화: 버킷에 저장되는 파일을 자동으로 암호화
# AES256: AWS 관리형 키를 사용하는 암호화 방식 (무료)

resource "aws_s3_bucket_server_side_encryption_configuration" "tfstate" {
  bucket = aws_s3_bucket.tfstate.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# 퍼블릭 액세스 차단: State 파일이 외부에 공개되는 것을 방지
# State에는 IP, ARN 등 민감 정보가 포함되어 있어 반드시 비공개로 유지

resource "aws_s3_bucket_public_access_block" "tfstate" {
  bucket = aws_s3_bucket.tfstate.id
  block_public_acls = true # ACL 로 퍼블릭 설정 차단
  block_public_policy = true # 버킷 정책으로 퍼블릭 설정 차단
  ignore_public_acls = true # 기존 퍼블릭 ACL 무시
  restrict_public_buckets = true # 퍼블릭 버킷 정책 거부
}

# DynamoDB 테이블: terraform apply 실행 중 다른 사람이 동시에 실행하는 것을 방지(Lock)
# 학습 환경에선 혼자 쓰지만, 실무에서는 동시 apply로 State가 꼬이는 것을 막는 역할

resource "aws_dynamodb_table" "tfstate_lock" {
  name = "infra-study-tfstate-lock-yongdong"
  billing_mode = "PAY_PER_REQUEST" # 사용한 만큼만 과금
  hash_key = "LockID" # Terraform이 Lock 정보를 저장할 때 쓰는 키 이름

  attribute {
    name = "LockID"
    type = "S" # S = String 타입
  }
}



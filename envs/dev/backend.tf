# backend "s3": Terraform State를 S3에 원격 저장하는 설정
# 이 파일 덕분에 어느 컴퓨터에서 실행해도 같은 State를 공유


terraform {
  backend "s3" {
    bucket         = "infra-study-tfstate-yongdong" # bootstrap에서 생성한 버킷
    key            = "dev/terraform.tfstate"        # S3 내 저장 경로 (환경마다 다르게 설정)
    region         = "ap-northeast-2"
    dynamodb_table = "infra-study-tfstate-lock-yongdong" # Lock용 DynamoDB 테이블
    encrypt        = true                                # S3 저장 시 추가 암호화
  }
}




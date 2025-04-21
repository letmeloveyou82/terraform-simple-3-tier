# terraform-simple-3-tier

## 🗂️ 아키텍처
![terraform_3-tier_간단 drawio](https://github.com/user-attachments/assets/38532408-4e4d-4f96-a3b7-89c68ce83798)

<br>

## 🛠️ 구성 순서

1단계 : VPC + Subnet + Routing Table + IGW + NAT Gateway 구성

2단계 : Web Tier의 Security Group + EC2 구성

3단계 : App Tier의 Security Group + EC2 구성

4단계 : DB Tier의 Security Group + DB Subnet Group 구성

<br>

## 🔐 민감한 값은 환경 변수로 주입

```bash
export TF_VAR_key_name=<생성한키페어이름>
export TF_VAR_db_username=<설정할DB유저이름>
export TF_VAR_db_password=<설정할DB패스워드>
```

- 키 페어는 미리 AWS 콘솔에서 생성

- terraform 명령어 실행할 vscode console 창에서 위 명령어들 작성

<br>

## 💻 EC2 user_data 예시

### 1. Web Tier의 EC2
    
```hcl
  user_data = <<-EOF
              #!/bin/bash
              sudo apt update -y
              sudo apt install -y nginx
              echo "<h1>Web Tier (80 OK)</h1>" > /var/www/html/index.html
              systemctl start nginx
              systemctl enable nginx
              EOF

```
    
### 2. App Tier의 EC2
    
```hcl
  user_data = <<-EOF
              #!/bin/bash
              exec > /var/log/user-data.log 2>&1
              sudo apt update -y || sudo yum update -y
              sudo apt install -y python3 || sudo yum install -y python3
              sudo apt install -y mysql-client
              echo "<h1>Hello from this EC2!</h1>" > /home/ubuntu/index.html
              cd /home/ubuntu
              nohup python3 -m http.server 8080 > http.log 2>&1 &
              EOF
```

## ❗ 발생할 수 있는 에러

![image (18)](https://github.com/user-attachments/assets/0c2f6eb6-1e0e-47bf-9cb1-2050f2f7dfc3)

RDS는 Multi-AZ를 true로 해두지 않아도 최소 2개 AZ에 걸친 서브넷을 요구합니다.

서브넷을 하나 더 만들고, 원래의 DB 서브넷과 추가한 서브넷을 db_subnet_group 리소스 정의할 때에 subnet_ids의 속성 값으로 넣어주면 됩니다.

## 🛠️ 자주 사용하는 명령어

### **1. 기본 워크플로 명령어**

| 명령어 | 설명 |
| --- | --- |
| `terraform init` | 해당 디렉토리에서 Terraform 초기화 (플러그인 다운로드 등) |
| `terraform plan` | 어떤 변경이 일어날지 미리 확인 (Dry-run) |
| `terraform apply` | 리소스 실제 생성 (변경 적용) |
| `terraform apply -auto-approve` | 자동 승인하고 바로 생성 |
| `terraform destroy` | 생성한 모든 리소스 삭제 |
| `terraform destroy -auto-approve` | 삭제 자동 승인 |

**⚠️ 상태 파일 관련 주의 사항**

| 주의 포인트 | 설명 |
| --- | --- |
| 💾 `terraform.tfstate`는 남아있음 | 리소스를 `destroy`해도 상태파일은 계속 남아있음 |
| 💡 완전히 새로 시작하고 싶으면? | `rm -rf .terraform terraform.tfstate*` 로 로컬 상태까지 정리 가능 |

---

### 2. **출력 & 상태 확인 명령어**

| 명령어 | 설명 |
| --- | --- |
| `terraform output` | 출력값 확인 (`output "..."` 항목) |
| `terraform output <이름>` | 특정 출력만 확인 |
| `terraform state list` | 현재 관리 중인 리소스 목록 확인 |
| `terraform state show <리소스>` | 특정 리소스 상세 정보 확인 |

---

### 3. **디버깅 & 테스트**

| 명령어 | 설명 |
| --- | --- |
| `terraform validate` | 문법 검증 (에러 확인용) |
| `terraform fmt` | 코드 포맷 정리 (자동 들여쓰기 등) |
| `terraform taint <리소스>` | 특정 리소스를 다시 생성하도록 표시 |
| `terraform untaint <리소스>` | taint 해제 |

---

### 4. **기타 유용한 명령**

| 명령어 | 설명 |
| --- | --- |
| `terraform show` | 현재 상태파일(.tfstate)의 전체 정보 출력 |
| `terraform graph` | 리소스 의존성 그래프 생성 (DOT 포맷) |
| `terraform version` | Terraform 버전 확인 |
| `terraform providers` | 현재 사용 중인 프로바이더 확인 |

---

## 📁 모듈화 프로젝트 구조 예시

```bash
terraform-project/
├── main.tf                  # 루트 main - 모듈 호출
├── variables.tf             # 루트에서 사용할 변수 정의
├── terraform.tfvars         # 루트에서 사용할 변수 값 지정
├── outputs.tf               # 루트에서 출력할 값 정의
├── providers.tf             # AWS provider, region 설정
└── modules/
    ├── vpc/
    │   ├── main.tf          # VPC, Subnet, IGW, NAT, Route Table 정의
    │   ├── variables.tf     # vpc_cidr, subnet_cidrs, azs 등
    │   └── outputs.tf       # vpc_id, subnet_ids 등 외부 전달용
    │
    ├── security-group/
    │   ├── main.tf          # web, app, db 계층용 SG 정의
    │   ├── variables.tf     # vpc_id, 포트 등 인자 정의
    │   └── outputs.tf       # 각 SG ID 출력
    │
    ├── ec2/
    │   ├── main.tf          # web/app EC2 생성
    │   ├── variables.tf     # AMI, 타입, 키페어, subnet_id, sg_id 등
    │   ├── outputs.tf       # 퍼블릭 IP 등
    │   └── user_data/
    │       ├── web.sh       # web 서버용 스크립트
    │       └── app.sh       # app 서버용 스크립트 
    │
    └── rds/
        ├── main.tf          # RDS, DB Subnet Group 생성
        ├── variables.tf     # DB 이름, 사용자, 비번, sg_id, subnet_group 등
        └── outputs.tf       # RDS endpoint 등

```

## 🔎 결과 확인

1. AWS 콘솔에서 네트워크 리소스 생성 확인

2. Web EC2 퍼블릭 IP로 접속 → nginx index.html 확인
3. Web EC2에서 `curl http://<app-ec2-private-ip>:8080` → App EC2 응답 확인
4. App EC2에서 `mysql -h <rds-endpoint> -u user -p` → DB 연결 테스트

## 📚 참고 자료

- [Creating a Highly Available 3-Tier Architecture for Web Applications in AWS](https://medium.com/@abach06/creating-a-highly-available-3-tier-architecture-for-web-applications-in-aws-23f37d49bd25)
  
- [Terraform AWS 공급자 사용 모범 사례](https://docs.aws.amazon.com/ko_kr/prescriptive-guidance/latest/terraform-aws-provider-best-practices/introduction.html)
- [Terraform Registry AWS Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs#argument-reference)
- [Terraform 공식 문서](https://developer.hashicorp.com/terraform/docs)

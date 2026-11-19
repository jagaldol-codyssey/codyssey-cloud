# EC2 실행·검증 순서

2026-11-19 아래 구성으로 실습하고 과금 리소스를 정리했다. [실제 실행 결과와 캡처](evidence/2026-11-19-session.md)를 함께 참고한다. 재실습 시 새 인스턴스의 IP를 사용한다.

## 1. 시작 전

- `codyssey-b3-lab` IAM 사용자로 로그인하고 서울 리전을 선택한다.
- [준비된 리소스 ID](setup.md#5-생성-결과)로 VPC·서브넷·IGW·라우팅·보안 그룹을 확인한다.
- SSH 인바운드의 내 IP `/32`를 현재 접속 환경에 맞게 갱신한다.
- 기존 프로젝트와 구분하기 위해 이 실습 리소스 이름에 `codyssey-b3-` 접두사를 사용한다.
- 캡처와 명령 결과를 저장할 위치를 준비한다. 개인키와 임시 로그인 정보는 `.local/`에만 보관한다.

## 2. EC2 생성

EC2 → 인스턴스 시작에서 아래 값을 선택한다. 마지막 시작 버튼부터 사용료가 발생한다.

| 항목 | 값 |
| --- | --- |
| 이름 | `codyssey-b3-web` |
| AMI | Canonical의 Ubuntu Server 24.04 LTS, 64비트 x86, 무료 OS 이미지 |
| 인스턴스 유형 / 개수 | `t3.micro` / 1 |
| 키 페어 | 새 RSA `.pem`, 이름 `codyssey-b3-key`; 다운로드 후 `.local/`에 보관 |
| VPC / 서브넷 | 준비한 `codyssey-b3` 전용 VPC / Public Subnet |
| 퍼블릭 IP 자동 할당 | 활성화 |
| 보안 그룹 | 준비한 `codyssey-b3-web-sg` 선택 |
| 스토리지 | gp3 8GiB, 기본 IOPS·처리량, 종료 시 삭제 활성화 |
| 고급 세부 정보 → 크레딧 사양 | Standard |
| IAM 인스턴스 프로파일 | 없음; 웹 서버는 AWS API를 사용하지 않음 |
| 메타데이터 | IMDSv2 필수 |
| 사용자 데이터 | `scripts/user-data.sh` 전체 내용 |

이름, 인스턴스 ID, 연결된 볼륨 ID와 퍼블릭 IP, 시작 시간을 기록한다. 시작 설정과 실행 중 상태를 캡처한다. 사용자 데이터는 첫 부팅에 root로 실행되며 Nginx를 설치한다.

## 3. SSH와 서버 내부 검증

로컬에서 실제 퍼블릭 IP를 대입한다.

```sh
chmod 400 .local/codyssey-b3-key.pem
ssh -i .local/codyssey-b3-key.pem ubuntu@<퍼블릭IP>
```

서버 안에서 아래 순서로 실행하고, 명령과 실제 결과를 `docs/evidence/`에 기록한다. 설치가 끝나기 전에는 웹 페이지가 열리지 않을 수 있다.

```sh
sudo cloud-init status --wait
sudo nginx -t
systemctl is-active nginx
curl -sS -I http://localhost/
curl -sS -I https://example.com
```

확인 조건은 Nginx 설정 검사 성공, 서비스 `active`, localhost의 HTTP 200, 외부 HTTPS 요청 성공이다. 설치 실패 시 `sudo tail -n 80 /var/log/cloud-init-output.log`로 원인을 확인한다. 로그를 공개하기 전 자격 증명과 불필요한 개인정보가 없는지 검토한다.

## 4. 외부 접속과 트러블슈팅

1. 로컬 브라우저 주소창에 `http://<퍼블릭IP>`를 입력한다. 주소창과 Nginx 기본 페이지가 보이도록 캡처한다.
2. README에 방식 A, 실제 URL과 확인 시각을 기록한다.
3. 자연 발생한 오류가 있으면 [보고서](troubleshooting.md)에 기록한다. 없다면 보고서의 HTTP 차단 재현 절차를 수행하고 복구한다.
4. 라우팅 테이블의 기본 경로와 서브넷 연결, 보안 그룹의 80·22 규칙, IAM 정책 연결 화면을 캡처한다.
5. 필요한 증거가 저장되었는지 확인한 즉시 [정리 체크리스트](cleanup-checklist.md)를 실행한다.

## 참고

- [AWS: 사용자 데이터 실행](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/user-data.html)
- [Ubuntu: Nginx 설치](https://ubuntu.com/server/docs/how-to/web-services/install-nginx/)
- [AWS: Standard 크레딧 설정](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/burstable-performance-instances-how-to.html)

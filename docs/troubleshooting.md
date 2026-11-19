# HTTP 인바운드 차단과 복구

실습일: 2026-11-19 · 보안 그룹: `codyssey-b3-web-sg`

| 단계 | 내용 |
| --- | --- |
| 증상 | HTTP TCP 80 규칙 제거 후 새 브라우저 요청이 `ERR_CONNECTION_TIMED_OUT`으로 실패 |
| 가설 | 보안 그룹이 외부 HTTP 연결을 차단 |
| 검증 | Nginx·라우팅·SSH 규칙을 유지하고 HTTP 규칙 제거 전·후·복구 후의 접속 결과 비교 |
| 조치 | HTTP TCP 80 / `0.0.0.0/0` 규칙 복구 |
| 결과 | `http://3.36.63.53/?check=recovered`에서 **Welcome to nginx!** 표시 |
| 재발 방지 | 보안 그룹 수정 후 HTTP·SSH 규칙 점검과 외부 접속 테스트 |

**차단 상태**

![HTTP 규칙 제거 후 연결 시간 초과](screenshots/20-http-timeout.jpg)

**복구 상태**

![HTTP 규칙 복구 후 정상 페이지](screenshots/22-http-recovered.jpg)

# DBMS 취약점 진단 모듈 Shell Spec (Phase 0)

## 1. 모듈 개요

| 항목 | 내용 |
|------|------|
| 모듈명 | dbms |
| 명령 prefix | dbm |
| 표준 ID prefix | DBM |
| 진단 항목 | DBM-001 ~ DBM-031 (31개) |
| 기준 파일 | 5. 26년_전금업_DBMS취약점(2).xlsx |
| Phase | 0 (read-only evidence mode) |

## 2. 허용 Profile

| profile | 대상 DBMS |
|---------|-----------|
| cloud_dbms | AWS RDS/Aurora, GCP Cloud SQL, Azure Database 등 관리형 DBMS |
| oracle | Oracle Database |
| mssql | Microsoft SQL Server |
| mysql | MySQL / MariaDB |
| postgresql | PostgreSQL |
| altibase | Altibase |
| tibero | Tibero |

## 3. 명령 체계

```bash
./main.sh dbm setup
./main.sh dbm audit --profile <profile> [--check <DBM-xxx>] [--dry-run]
./main.sh dbm report
./main.sh dbm verify --profile <profile> --check <DBM-xxx>
```

## 4. Phase 0 정책

| 정책 | 값 |
|------|-----|
| AUDIT_ONLY | true |
| DRY_RUN (기본) | true |
| REMEDIATE | false |
| DIRECT_DB_ACCESS | false |
| NOT_IMPLEMENTED_AS_PASS | false |
| EVIDENCE_REQUIRED | true |

## 5. 디렉터리 구조

```text
config/dbms/               # 프로파일별 설정 파일
input/evidence/dbms/       # 입력 증적 파일
shell_script/dbms/         # 점검 스크립트
runners/
  dbms_runner.sh           # 오케스트레이터
  safety_guard.sh          # 위험 명령 차단
  result_normalizer.sh     # 7-state 정규화
  evidence_collector.sh    # 증적 수집·manifest
output/
  json/                    # 결과 JSON
  csv/                     # 결과 CSV
  html/                    # HTML 보고서
  pdf/                     # PDF 보고서
  evidence/dbms/           # 실행 증적
  logs/                    # 실행 로그
tools/
  dbm_json_to_csv.py
  dbm_json_to_html.py
  dbm_html_to_pdf.py
templates/
  dbm_style.css
```

## 6. 표준 상태값

| 상태 | 의미 | PASS 집계 |
|------|------|-----------|
| PASS | 양호 | O |
| FAIL | 취약 | X |
| NA | 해당 없음 | X |
| MANUAL_REVIEW | 수동 검토 필요 | X |
| EVIDENCE_MISSING | 증적 없음 | X |
| ERROR | 오류 | X |
| NOT_IMPLEMENTED | 미구현 | X |

## 7. PASS 확정 조건

1. 증적 파일이 2개 이상 존재하고 모두 유효 내용이 있어야 한다.
2. 양호 키워드가 2개 이상 독립 확인되어야 한다.
3. 단일 키워드만 발견되면 MANUAL_REVIEW.
4. 증적 없는 PASS → EVIDENCE_MISSING 자동 강등.

## 8. safety_guard 차단 패턴

### 차단 대상 (실행 컨텍스트)

- DB client 직접 실행: sqlplus, sqlcmd, mysql -u, psql, isql, tbSQL
- SQL 파이프: echo "..." | sqlplus, sqlcmd -Q "...", psql -c "..."
- 위험 시스템 명령: rm -rf, sed -i, chmod 777
- Listener 조작: lsnrctl stop/start/reload
- DBMS 서비스 재시작: systemctl restart/stop <dbms>

### 허용 대상 (증적 파일 읽기)

```bash
grep -i "GRANT" roles.txt            # ✅ 허용
grep -i "ALTER USER" audit_log.txt   # ✅ 허용
cat xp_cmdshell_status.txt | grep 0  # ✅ 허용
```

## 9. MSSQL 전용 항목

| ID | 항목 | 비MSSQL |
|----|------|---------|
| DBM-026 | SA 계정 보안설정 | NA |
| DBM-030 | xp_cmdshell 비활성화 | NA |
| DBM-031 | Registry Procedure 권한 | NA |

## 10. cloud_dbms NA 항목

OS 직접 설정, Listener 직접 제어, ODBC/OLE-DB 드라이버 제거, DBMS 서비스 구동 계정, umask 등 관리형 DBMS에서 고객이 직접 통제하지 않는 항목은 NA 또는 MANUAL_REVIEW.

## 11. Phase 1+ 예정 작업

1. Oracle/MSSQL/MySQL/PostgreSQL/Altibase/Tibero별 export 파서 고도화
2. Read-only SQL 접속 모드 (Phase 1)
3. DB 계정/권한/Role 자동 판단 고도화
4. 패치/EOS/EOL 정보 외부 조회 연계
5. 증적 ZIP 생성 및 Hash 검증
6. 전자금융감독규정/시행세칙 매핑 보고서
7. HTML/PDF 디자인 고도화
8. 재점검 before/after 비교 기능

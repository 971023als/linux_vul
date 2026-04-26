#!/bin/bash
# runners/dbms_runner.sh
# -----------------------------------------------------------------------------
# [DBMS Runner] DBMS 취약점 진단 Phase 0 오케스트레이터
#
# 사용법:
#   dbms_runner.sh --action setup
#   dbms_runner.sh --action audit --profile oracle [--check DBM-001] [--dry-run]
# -----------------------------------------------------------------------------

set -u

RUNNER_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "${RUNNER_DIR}/.." && pwd)"

ACTION=""
PROFILE=""
CHECK_ID=""
DRY_RUN=false

# Phase 0 강제 정책
AUDIT_ONLY=true
DIRECT_DB_ACCESS=false
NOT_IMPLEMENTED_AS_PASS=false
EVIDENCE_REQUIRED=true

# 색상
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'; NC='\033[0m'

while [[ $# -gt 0 ]]; do
    case "$1" in
        --action)   ACTION="${2:-}";   shift 2 ;;
        --profile)  PROFILE="${2:-}";  shift 2 ;;
        --check)    CHECK_ID="${2:-}"; shift 2 ;;
        --dry-run)  DRY_RUN=true;      shift ;;
        # Phase 0 금지 옵션
        --db-host|--db-user|--db-password|--jdbc-url|--odbc-dsn)
            echo -e "${YELLOW}[runner] Phase 0: DB 접속 옵션 무시 (${1}). DIRECT_DB_ACCESS=false 강제.${NC}" >&2
            shift 2
            ;;
        *) shift ;;
    esac
done

# =============================================================================
# 허용 profile 목록
# =============================================================================
ALLOWED_PROFILES=("cloud_dbms" "oracle" "mssql" "mysql" "postgresql" "altibase" "tibero")

# =============================================================================
# setup 액션
# =============================================================================
if [[ "$ACTION" == "setup" ]]; then
    echo -e "${CYAN}[setup] DBMS 모듈 디렉터리 구조 초기화...${NC}"

    for p in "${ALLOWED_PROFILES[@]}"; do
        mkdir -p \
            "${PROJECT_DIR}/input/evidence/dbms/${p}" \
            "${PROJECT_DIR}/output/evidence/dbms/${p}" \
            "${PROJECT_DIR}/shell_script/dbms/${p}" \
            "${PROJECT_DIR}/config/dbms"

        # 공통 증적 샘플 파일
        for fname in users.txt admin_users.txt password_policy.txt failed_login_policy.txt \
                     password_lifetime.txt session_timeout.txt audit_config.txt audit_backup.txt \
                     listener_config.txt remote_access.txt roles.txt public_role_privileges.txt \
                     patch_status.txt system_table_privileges.txt password_reuse_policy.txt \
                     object_list.txt resource_limit.txt audit_table_privileges.txt \
                     encryption_status.txt network_encryption.txt ha_config.txt \
                     service_account.txt file_permissions.txt change_approval.csv; do
            TARGET="${PROJECT_DIR}/input/evidence/dbms/${p}/${fname}"
            if [[ ! -f "$TARGET" ]]; then
                cat > "$TARGET" << STUB
# [샘플 증적] ${p} / ${fname}
# -----------------------------------------------------------------------------
# 이 파일은 Phase 0 진단을 위한 샘플 증적 파일입니다.
# 실제 시스템에서 export한 결과로 교체하십시오.
# placeholder-only 파일은 유효 증적으로 인정되지 않습니다.
# -----------------------------------------------------------------------------
STUB
            fi
        done

        # MSSQL 전용 증적 파일
        if [[ "$p" == "mssql" ]]; then
            for fname in sa_status.txt xp_cmdshell_status.txt registry_procedure_privileges.txt; do
                TARGET="${PROJECT_DIR}/input/evidence/dbms/mssql/${fname}"
                if [[ ! -f "$TARGET" ]]; then
                    cat > "$TARGET" << STUB
# [샘플 증적] mssql / ${fname}
# MSSQL 전용 증적 파일입니다. 실제 export 결과로 교체하십시오.
STUB
                fi
            done
        fi

        # cloud_dbms 전용 증적 파일
        if [[ "$p" == "cloud_dbms" ]]; then
            for fname in parameter_group_export.txt cloud_account_export.txt audit_log_export.txt \
                         encryption_config_export.txt backup_config_export.txt cloud_access_control_export.txt; do
                TARGET="${PROJECT_DIR}/input/evidence/dbms/cloud_dbms/${fname}"
                if [[ ! -f "$TARGET" ]]; then
                    cat > "$TARGET" << STUB
# [샘플 증적] cloud_dbms / ${fname}
# 클라우드 관리형 DBMS 증적 파일입니다. 실제 export 결과로 교체하십시오.
STUB
                fi
            done
        fi
    done

    mkdir -p \
        "${PROJECT_DIR}/output/json" \
        "${PROJECT_DIR}/output/csv" \
        "${PROJECT_DIR}/output/html" \
        "${PROJECT_DIR}/output/pdf" \
        "${PROJECT_DIR}/output/logs" \
        "${PROJECT_DIR}/templates"

    echo -e "${GREEN}[setup] 완료.${NC}"
    exit 0
fi

# =============================================================================
# audit 액션
# =============================================================================
if [[ "$ACTION" != "audit" ]]; then
    echo -e "${RED}[runner] 알 수 없는 action: ${ACTION}${NC}" >&2
    exit 1
fi

# ------------------------------------------------------------------
# 카탈로그 로드 (항목 목록 결정)
# ------------------------------------------------------------------
CATALOG_FILE="${PROJECT_DIR}/dbms_check_catalog.json"
if [[ ! -f "$CATALOG_FILE" ]]; then
    echo -e "${RED}[runner] dbms_check_catalog.json 없음: ${CATALOG_FILE}${NC}" >&2
    exit 1
fi

# 이번 profile에서 실행할 check_id 목록 결정
if [[ -n "$CHECK_ID" ]]; then
    # 단일 항목 – 유효성 확인
    ID_EXISTS=$(python3 -c "
import json
with open('$CATALOG_FILE') as f:
    catalog = json.load(f)
ids = [item['id'] for item in catalog]
print('YES' if '$CHECK_ID' in ids else 'NO')
" 2>/dev/null)
    if [[ "$ID_EXISTS" != "YES" ]]; then
        # DBM-xxx 형식이지만 범위 밖이면 NOT_IMPLEMENTED
        TS=$(date +%Y%m%d_%H%M%S)
        _write_not_impl() {
            python3 - << PYEOF
import json, os, datetime
result = {
    "id": "$CHECK_ID",
    "profile": "$PROFILE",
    "status": "NOT_IMPLEMENTED",
    "reason": "카탈로그에 없는 점검 ID",
    "generated_at": datetime.datetime.utcnow().isoformat() + "Z"
}
print(json.dumps(result, ensure_ascii=False, indent=2))
PYEOF
        }
        echo -e "${YELLOW}[runner] ${CHECK_ID}: NOT_IMPLEMENTED (카탈로그에 없는 ID)${NC}"
        _write_not_impl
        exit 0
    fi
    CHECK_IDS=("$CHECK_ID")
else
    # 전체 항목 – 현재 profile에 적용되는 항목만 선택
    mapfile -t CHECK_IDS < <(python3 -c "
import json
with open('$CATALOG_FILE') as f:
    catalog = json.load(f)
for item in catalog:
    if '$PROFILE' in item.get('profiles', []):
        print(item['id'])
" 2>/dev/null)
fi

echo -e "${CYAN}[runner] profile=${PROFILE} 실행 항목: ${#CHECK_IDS[@]}개${NC}"

# ------------------------------------------------------------------
# 결과 누적 구조
# ------------------------------------------------------------------
TS=$(date +%Y%m%d_%H%M%S)
RESULT_TS_FILE="${PROJECT_DIR}/output/json/dbms_assessment_result_${TS}.json"
RESULT_LATEST="${PROJECT_DIR}/output/json/dbms_assessment_result.json"
LOG_FILE="${PROJECT_DIR}/output/logs/dbms_runner_${TS}.log"
mkdir -p "${PROJECT_DIR}/output/json" "${PROJECT_DIR}/output/logs"

# 임시 파일로 결과 누적 (쉘 변수 경유 시 JSON 이스케이프 오염 방지)
RESULTS_FILE=$(mktemp /tmp/dbm_results_XXXXXX.json)
trap 'rm -f "$RESULTS_FILE"' EXIT
echo '[]' > "$RESULTS_FILE"

# ------------------------------------------------------------------
# 항목별 실행 루프
# ------------------------------------------------------------------
PASS=0; FAIL=0; NA=0; MANUAL=0; MISSING=0; ERROR_COUNT=0; NOT_IMPL=0; TOTAL=0

for CID in "${CHECK_IDS[@]}"; do
    TOTAL=$((TOTAL + 1))
    echo -e "${CYAN}[runner] ── ${CID} 시작...${NC}"

    # 카탈로그에서 메타데이터 조회
    META_FILE=$(mktemp /tmp/dbm_meta_XXXXXX.json)
    python3 -c "
import json, sys
with open('$CATALOG_FILE') as f:
    catalog = json.load(f)
for item in catalog:
    if item['id'] == '$CID':
        print(json.dumps(item, ensure_ascii=False))
        sys.exit(0)
print('{}')
" 2>/dev/null > "$META_FILE"

    TITLE=$(python3 -c "import json; d=json.load(open('$META_FILE')); print(d.get('title',''))" 2>/dev/null || echo "")
    RISK=$(python3  -c "import json; d=json.load(open('$META_FILE')); print(d.get('risk_level',3))" 2>/dev/null || echo "3")
    SEVERITY=$(python3 -c "import json; d=json.load(open('$META_FILE')); print(d.get('severity_label','MEDIUM'))" 2>/dev/null || echo "MEDIUM")
    NA_PROFILES_LIST=$(python3 -c "import json; d=json.load(open('$META_FILE')); print('\n'.join(d.get('na_profiles',[])))" 2>/dev/null || echo "")

    # NA 판정 (이 profile이 na_profiles에 포함되면)
    if echo "$NA_PROFILES_LIST" | grep -qx "$PROFILE"; then
        echo -e "${YELLOW}[runner] ${CID}: NA (적용 대상 아님: ${PROFILE})${NC}"
        NA=$((NA + 1))
        python3 - "$RESULTS_FILE" "$META_FILE" << PYEOF
import json, sys
rf, mf = sys.argv[1], sys.argv[2]
arr  = json.load(open(rf))
meta = json.load(open(mf))
arr.append({
    "id": "$CID",
    "source_id": "",
    "title": meta.get("title", ""),
    "profile": "$PROFILE",
    "risk_level": meta.get("risk_level", 3),
    "severity_label": meta.get("severity_label", "MEDIUM"),
    "status": "NA",
    "reason": "이 DBMS 유형에 해당 없는 항목",
    "script": {"path": "", "runner": "", "exit_code": 0},
    "raw_output_path": "",
    "error_output_path": "",
    "input_evidence_path": "input/evidence/dbms/$PROFILE/",
    "evidence": [],
    "description": meta.get("description", ""),
    "recommendation": meta.get("recommendation", ""),
    "manual_review_required": False,
    "error_message": None
})
json.dump(arr, open(rf, "w"), ensure_ascii=False)
PYEOF
        rm -f "$META_FILE"
        continue
    fi

    # 스크립트 경로 결정
    SCRIPT_PATH="${PROJECT_DIR}/shell_script/dbms/${PROFILE}/${CID}.sh"
    INPUT_DIR="${PROJECT_DIR}/input/evidence/dbms/${PROFILE}"
    OUT_DIR="${PROJECT_DIR}/output/evidence/dbms/${PROFILE}/${CID}"
    mkdir -p "$OUT_DIR"

    # 스크립트 없음 → NOT_IMPLEMENTED
    if [[ ! -f "$SCRIPT_PATH" ]]; then
        echo -e "${YELLOW}[runner] ${CID}: NOT_IMPLEMENTED (스크립트 없음)${NC}"
        NOT_IMPL=$((NOT_IMPL + 1))
        echo "NOT_IMPLEMENTED" > "${OUT_DIR}/status.txt"
        echo "스크립트가 구현되지 않았습니다: ${SCRIPT_PATH}" > "${OUT_DIR}/stdout.txt"
        echo "" > "${OUT_DIR}/stderr.txt"
        echo "0" > "${OUT_DIR}/exit_code.txt"
        python3 - "$RESULTS_FILE" "$META_FILE" << PYEOF
import json, sys
rf, mf = sys.argv[1], sys.argv[2]
arr  = json.load(open(rf))
meta = json.load(open(mf))
arr.append({
    "id": "$CID",
    "source_id": "",
    "title": meta.get("title", ""),
    "profile": "$PROFILE",
    "risk_level": meta.get("risk_level", 3),
    "severity_label": meta.get("severity_label", "MEDIUM"),
    "status": "NOT_IMPLEMENTED",
    "reason": "스크립트가 구현되지 않았습니다",
    "script": {"path": "$SCRIPT_PATH", "runner": "bash", "exit_code": 0},
    "raw_output_path": "${OUT_DIR}/stdout.txt",
    "error_output_path": "${OUT_DIR}/stderr.txt",
    "input_evidence_path": "$INPUT_DIR/",
    "evidence": [],
    "description": meta.get("description", ""),
    "recommendation": meta.get("recommendation", ""),
    "manual_review_required": False,
    "error_message": None
})
json.dump(arr, open(rf, "w"), ensure_ascii=False)
PYEOF
        rm -f "$META_FILE"
        continue
    fi

    # safety_guard 검사
    GUARD_RESULT=$("${RUNNER_DIR}/safety_guard.sh" "$SCRIPT_PATH" 2>/dev/null)
    GUARD_EXIT=$?
    if [[ "$GUARD_EXIT" -ne 0 ]]; then
        echo -e "${RED}[runner] ${CID}: ERROR (safety_guard 차단)${NC}"
        echo "$GUARD_RESULT" > "${OUT_DIR}/stdout.txt"
        echo "safety_guard 차단" > "${OUT_DIR}/stderr.txt"
        echo "1" > "${OUT_DIR}/exit_code.txt"
        ERROR_COUNT=$((ERROR_COUNT + 1))
        GUARD_FILE=$(mktemp /tmp/dbm_guard_XXXXXX.json)
        echo "$GUARD_RESULT" > "$GUARD_FILE"
        python3 - "$RESULTS_FILE" "$META_FILE" "$GUARD_FILE" << PYEOF
import json, sys
rf, mf, gf = sys.argv[1], sys.argv[2], sys.argv[3]
arr   = json.load(open(rf))
meta  = json.load(open(mf))
guard = json.load(open(gf)) if open(gf).read().strip() else {}
ucmd  = guard.get("unsafe_command", "unknown")
arr.append({
    "id": "$CID",
    "source_id": "",
    "title": meta.get("title", ""),
    "profile": "$PROFILE",
    "risk_level": meta.get("risk_level", 3),
    "severity_label": meta.get("severity_label", "MEDIUM"),
    "status": "ERROR",
    "reason": "safety_guard: 위험 명령 감지로 실행 차단",
    "script": {"path": "$SCRIPT_PATH", "runner": "bash", "exit_code": 1},
    "raw_output_path": "${OUT_DIR}/stdout.txt",
    "error_output_path": "${OUT_DIR}/stderr.txt",
    "input_evidence_path": "$INPUT_DIR/",
    "evidence": [f"unsafe_command: {ucmd}"],
    "description": meta.get("description", ""),
    "recommendation": meta.get("recommendation", ""),
    "manual_review_required": False,
    "error_message": f"unsafe_command: {ucmd}"
})
json.dump(arr, open(rf, "w"), ensure_ascii=False)
PYEOF
        rm -f "$META_FILE" "$GUARD_FILE"
        continue
    fi

    # dry-run 모드: 실행하지 않고 MANUAL_REVIEW 처리
    if [[ "$DRY_RUN" == "true" ]]; then
        echo -e "${CYAN}[runner] ${CID}: DRY-RUN (실행 건너뜀, 스크립트 존재 확인됨)${NC}"
        echo "STATUS=MANUAL_REVIEW" > "${OUT_DIR}/stdout.txt"
        echo "REASON=dry-run 모드 – 실제 실행 생략" >> "${OUT_DIR}/stdout.txt"
        echo "EVIDENCE=스크립트 존재 확인: ${SCRIPT_PATH}" >> "${OUT_DIR}/stdout.txt"
        echo "" > "${OUT_DIR}/stderr.txt"
        echo "0" > "${OUT_DIR}/exit_code.txt"
    else
        # 실제 실행
        STDOUT_TMP=$(mktemp)
        STDERR_TMP=$(mktemp)
        bash "$SCRIPT_PATH" \
            --input-dir "$INPUT_DIR" \
            --check-id "$CID" \
            2>"$STDERR_TMP" > "$STDOUT_TMP"
        EXEC_EXIT=$?
        cp "$STDOUT_TMP" "${OUT_DIR}/stdout.txt"
        cp "$STDERR_TMP" "${OUT_DIR}/stderr.txt"
        echo "$EXEC_EXIT" > "${OUT_DIR}/exit_code.txt"
        rm -f "$STDOUT_TMP" "$STDERR_TMP"
    fi

    # result_normalizer 호출
    NORM_FILE=$(mktemp /tmp/dbm_norm_XXXXXX.json)
    "${RUNNER_DIR}/result_normalizer.sh" \
        --stdout     "${OUT_DIR}/stdout.txt" \
        --stderr     "${OUT_DIR}/stderr.txt" \
        --exit-code  "$(cat "${OUT_DIR}/exit_code.txt")" \
        --evidence-dir "$INPUT_DIR" \
        --check-id   "$CID" 2>/dev/null > "$NORM_FILE"

    NORM_STATUS=$(python3 -c "import json; d=json.load(open('$NORM_FILE')); print(d.get('status','ERROR'))" 2>/dev/null || echo "ERROR")
    NORM_REASON=$(python3 -c "import json; d=json.load(open('$NORM_FILE')); print(d.get('reason',''))" 2>/dev/null || echo "")

    cp "$NORM_FILE" "${OUT_DIR}/normalized_result.json"

    # evidence_collector 호출
    "${RUNNER_DIR}/evidence_collector.sh" \
        --check-id   "$CID" \
        --profile    "$PROFILE" \
        --script     "$SCRIPT_PATH" \
        --stdout     "${OUT_DIR}/stdout.txt" \
        --stderr     "${OUT_DIR}/stderr.txt" \
        --exit-code  "$(cat "${OUT_DIR}/exit_code.txt")" \
        --input-dir  "$INPUT_DIR" \
        --output-dir "$OUT_DIR" >> "$LOG_FILE" 2>&1

    # 집계
    case "$NORM_STATUS" in
        PASS)              PASS=$((PASS + 1)) ;;
        FAIL)              FAIL=$((FAIL + 1)) ;;
        NA)                NA=$((NA + 1)) ;;
        MANUAL_REVIEW)     MANUAL=$((MANUAL + 1)) ;;
        EVIDENCE_MISSING)  MISSING=$((MISSING + 1)) ;;
        ERROR)             ERROR_COUNT=$((ERROR_COUNT + 1)) ;;
        NOT_IMPLEMENTED)   NOT_IMPL=$((NOT_IMPL + 1)) ;;
    esac

    STATUS_COLOR="$YELLOW"
    [[ "$NORM_STATUS" == "PASS" ]] && STATUS_COLOR="$GREEN"
    [[ "$NORM_STATUS" == "FAIL" ]] && STATUS_COLOR="$RED"
    echo -e "[runner] ${CID}: ${STATUS_COLOR}${NORM_STATUS}${NC} – ${NORM_REASON}"

    # 결과 배열에 추가 (임시 파일 경유 – 이스케이프 오염 방지)
    python3 - "$RESULTS_FILE" "$META_FILE" "$NORM_FILE" "${OUT_DIR}/exit_code.txt" << PYEOF
import json, sys, os
rf, mf, nf, ecf = sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4]
arr  = json.load(open(rf))
meta = json.load(open(mf))
norm = json.load(open(nf)) if os.path.getsize(nf) > 0 else {}

# 증적 목록
evs = []
idir = "$INPUT_DIR"
if os.path.isdir(idir):
    for fn in sorted(os.listdir(idir)):
        fp = os.path.join(idir, fn)
        if os.path.isfile(fp):
            evs.append(f"{fn} ({os.path.getsize(fp)} bytes)")

exit_code = int(open(ecf).read().strip() or "0")
norm_status = norm.get("status", "ERROR")
norm_reason = norm.get("reason", "")
arr.append({
    "id": "$CID",
    "source_id": "",
    "title": meta.get("title", ""),
    "profile": "$PROFILE",
    "risk_level": meta.get("risk_level", 3),
    "severity_label": meta.get("severity_label", "MEDIUM"),
    "status": norm_status,
    "reason": norm_reason,
    "script": {
        "path": "$SCRIPT_PATH",
        "runner": "bash",
        "exit_code": exit_code
    },
    "raw_output_path": "${OUT_DIR}/stdout.txt",
    "error_output_path": "${OUT_DIR}/stderr.txt",
    "input_evidence_path": "$INPUT_DIR/",
    "evidence": evs,
    "description": meta.get("description", ""),
    "recommendation": meta.get("recommendation", ""),
    "manual_review_required": norm_status in ("MANUAL_REVIEW", "EVIDENCE_MISSING"),
    "error_message": norm_reason if norm_status in ("ERROR", "NOT_IMPLEMENTED") else None
})
json.dump(arr, open(rf, "w"), ensure_ascii=False)
PYEOF

    rm -f "$META_FILE" "$NORM_FILE"

done  # end for CID

# ------------------------------------------------------------------
# 최종 결과 JSON 작성
# ------------------------------------------------------------------
ASSESSMENT_ID="dbm-${TS}"

python3 - "$RESULTS_FILE" << PYEOF
import json, datetime, shutil, sys
rf = sys.argv[1]
results = json.load(open(rf))

# source_id 보강
try:
    with open("$CATALOG_FILE") as f:
        catalog = json.load(f)
    cat_map = {c["id"]: c for c in catalog}
    for r in results:
        if r["id"] in cat_map:
            r["source_id"] = cat_map[r["id"]].get("source_id", "")
except:
    pass

output = {
    "assessment_id": "$ASSESSMENT_ID",
    "tool": {
        "name": "dbms-assessor",
        "version": "0.1",
        "baseline_file": "5. 26년_전금업_DBMS취약점(2).xlsx"
    },
    "target": {
        "profile": "$PROFILE",
        "scope": "dbms",
        "asset_name": "masked",
        "ip": "masked"
    },
    "policy": {
        "audit_only": True,
        "dry_run": $([[ "$DRY_RUN" == "true" ]] && echo "True" || echo "False"),
        "remediate": False,
        "direct_db_access": False,
        "not_implemented_as_pass": False,
        "evidence_required": True
    },
    "summary": {
        "total": $TOTAL,
        "applicable": $((TOTAL - NA)),
        "pass": $PASS,
        "fail": $FAIL,
        "na": $NA,
        "manual_review": $MANUAL,
        "evidence_missing": $MISSING,
        "error": $ERROR_COUNT,
        "not_implemented": $NOT_IMPL
    },
    "results": results,
    "generated_at": datetime.datetime.utcnow().isoformat() + "Z"
}

with open("$RESULT_TS_FILE", "w") as f:
    json.dump(output, f, ensure_ascii=False, indent=2)
shutil.copy("$RESULT_TS_FILE", "$RESULT_LATEST")
print(f"결과 저장: $RESULT_TS_FILE")
print(f"latest:  $RESULT_LATEST")
PYEOF

echo ""
echo -e "${YELLOW}========================================${NC}"
echo -e "${CYAN}[결과 요약] profile=${PROFILE}${NC}"
echo -e "  전체:           ${TOTAL}"
echo -e "  ${GREEN}PASS:           ${PASS}${NC}"
echo -e "  ${RED}FAIL:           ${FAIL}${NC}"
echo -e "  NA:             ${NA}"
echo -e "  MANUAL_REVIEW:  ${MANUAL}"
echo -e "  EVIDENCE_MISSING: ${MISSING}"
echo -e "  ERROR:          ${ERROR_COUNT}"
echo -e "  NOT_IMPLEMENTED: ${NOT_IMPL}"
echo -e "${YELLOW}========================================${NC}"
echo -e "${GREEN}[완료] ${RESULT_LATEST}${NC}"

exit 0

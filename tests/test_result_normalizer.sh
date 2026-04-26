#!/bin/bash
# tests/test_result_normalizer.sh
# result_normalizer.sh 단위 테스트

cd "$(dirname "${BASH_SOURCE[0]}")/.." || exit 1

PASS_COUNT=0; FAIL_COUNT=0
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; NC='\033[0m'
TMP_DIR=$(mktemp -d)
trap 'rm -rf "$TMP_DIR"' EXIT

assert_status() {
    local label="$1" stdout_content="$2" stderr_content="$3" exit_code="$4" expected_status="$5"
    local so="${TMP_DIR}/so_$$.txt" se="${TMP_DIR}/se_$$.txt"
    echo "$stdout_content" > "$so"
    echo "$stderr_content" > "$se"
    local result
    result=$(bash runners/result_normalizer.sh \
        --stdout "$so" --stderr "$se" --exit-code "$exit_code" \
        --evidence-dir "" --check-id "TEST" 2>/dev/null)
    local got
    got=$(echo "$result" | python3 -c "import json,sys; d=json.load(sys.stdin); print(d.get('status',''))" 2>/dev/null)
    if [[ "$got" == "$expected_status" ]]; then
        echo -e "  ${GREEN}✅ PASS${NC} $label (→ $got)"
        PASS_COUNT=$((PASS_COUNT+1))
    else
        echo -e "  ${RED}❌ FAIL${NC} $label (expected=$expected_status, got=$got)"
        FAIL_COUNT=$((FAIL_COUNT+1))
    fi
}

echo -e "${YELLOW}=== result_normalizer 단위 테스트 ===${NC}"

# ── 매핑 테스트
# 증적 없는 경우: 스펙 상 PASS → EVIDENCE_MISSING 강등이 올바름
assert_status "양호+증적없음 → EVIDENCE_MISSING" "STATUS=양호" "" 0 "EVIDENCE_MISSING"
assert_status "PASS+증적없음 → EVIDENCE_MISSING" "STATUS=PASS" "" 0 "EVIDENCE_MISSING"
assert_status "취약 → FAIL"       "STATUS=취약"        "" 0 "FAIL"
assert_status "FAIL → FAIL"       "STATUS=FAIL"        "" 0 "FAIL"
assert_status "NA → NA"           "STATUS=NA"          "" 0 "NA"
assert_status "N/A → NA"          "STATUS=N/A"         "" 0 "NA"
assert_status "MANUAL_REVIEW"     "STATUS=MANUAL_REVIEW" "" 0 "MANUAL_REVIEW"
assert_status "수동점검 → MANUAL" "STATUS=수동점검"    "" 0 "MANUAL_REVIEW"
assert_status "EVIDENCE_MISSING"  "STATUS=EVIDENCE_MISSING" "" 0 "EVIDENCE_MISSING"
assert_status "NOT_IMPLEMENTED"   "STATUS=NOT_IMPLEMENTED" "" 0 "NOT_IMPLEMENTED"
assert_status "ERROR exit non-0"  "STATUS=ERROR"       "some error" 1 "ERROR"

# ── 빈 stdout + exit 0 → MANUAL_REVIEW
assert_status "빈 stdout exit 0 → MANUAL_REVIEW" "" "" 0 "MANUAL_REVIEW"

# ── stderr + non-zero → ERROR
assert_status "stderr + non-zero → ERROR" "STATUS=PASS" "connection refused" 1 "ERROR"

# ── 알 수 없는 상태 → MANUAL_REVIEW
assert_status "unknown status → MANUAL_REVIEW" "STATUS=UNKNOWN_XYZ" "" 0 "MANUAL_REVIEW"

# ── 실제 증적 있는 PASS → PASS 유지
REAL_EV="${TMP_DIR}/real_ev"
mkdir -p "$REAL_EV"
echo "password_verify_function = complex_check" > "${REAL_EV}/password_policy.txt"
echo "PROFILE: strict_pass" >> "${REAL_EV}/password_policy.txt"
so_p="${TMP_DIR}/pass_so.txt"
echo "STATUS=PASS" > "$so_p"
echo "REASON=2개 이상 증적 확인" >> "$so_p"
se_p="${TMP_DIR}/pass_se.txt"
echo "" > "$se_p"
result=$(bash runners/result_normalizer.sh \
    --stdout "$so_p" --stderr "$se_p" --exit-code 0 \
    --evidence-dir "$REAL_EV" --check-id "TEST" 2>/dev/null)
got=$(echo "$result" | python3 -c "import json,sys; d=json.load(sys.stdin); print(d.get('status',''))" 2>/dev/null)
if [[ "$got" == "PASS" ]]; then
    echo -e "  ${GREEN}✅ PASS${NC} 실제 증적 있는 PASS → PASS 유지"
    PASS_COUNT=$((PASS_COUNT+1))
else
    echo -e "  ${RED}❌ FAIL${NC} 실제 증적 있는 PASS → PASS 유지 (got=$got)"
    FAIL_COUNT=$((FAIL_COUNT+1))
fi

# ── 증적 없는 PASS → EVIDENCE_MISSING (빈 evidence-dir 사용 시 EVIDENCE_MISSING으로 강등)
# evidence-dir을 빈 디렉터리로 지정
EMPTY_EV="${TMP_DIR}/empty_ev"
mkdir -p "$EMPTY_EV"
so="${TMP_DIR}/ev_so.txt"
echo "STATUS=PASS" > "$so"
se="${TMP_DIR}/ev_se.txt"
echo "" > "$se"
result=$(bash runners/result_normalizer.sh \
    --stdout "$so" --stderr "$se" --exit-code 0 \
    --evidence-dir "$EMPTY_EV" --check-id "TEST" 2>/dev/null)
got=$(echo "$result" | python3 -c "import json,sys; d=json.load(sys.stdin); print(d.get('status',''))" 2>/dev/null)
if [[ "$got" == "EVIDENCE_MISSING" ]]; then
    echo -e "  ${GREEN}✅ PASS${NC} 증적없는 PASS → EVIDENCE_MISSING 강등"
    PASS_COUNT=$((PASS_COUNT+1))
else
    echo -e "  ${RED}❌ FAIL${NC} 증적없는 PASS → EVIDENCE_MISSING 강등 (got=$got)"
    FAIL_COUNT=$((FAIL_COUNT+1))
fi

echo ""
echo -e "${YELLOW}=== 결과 ===${NC}"
echo -e "  PASS: ${GREEN}${PASS_COUNT}${NC}"
echo -e "  FAIL: ${RED}${FAIL_COUNT}${NC}"
[[ "$FAIL_COUNT" -eq 0 ]] && exit 0 || exit 1

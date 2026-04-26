#!/bin/bash
# tests/test_dbms_runner.sh
# DBMS Runner 통합 테스트
# 사용법: bash tests/test_dbms_runner.sh

cd "$(dirname "${BASH_SOURCE[0]}")/.." || exit 1

PASS_COUNT=0; FAIL_COUNT=0
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; NC='\033[0m'

assert_contains() {
    local label="$1" output="$2" expected="$3"
    if echo "$output" | grep -q "$expected"; then
        echo -e "  ${GREEN}✅ PASS${NC} $label"
        PASS_COUNT=$((PASS_COUNT+1))
    else
        echo -e "  ${RED}❌ FAIL${NC} $label (expected: '$expected')"
        echo "     output: $output" | head -3
        FAIL_COUNT=$((FAIL_COUNT+1))
    fi
}

assert_exit() {
    local label="$1" actual="$2" expected="$3"
    if [[ "$actual" -eq "$expected" ]]; then
        echo -e "  ${GREEN}✅ PASS${NC} $label (exit=$actual)"
        PASS_COUNT=$((PASS_COUNT+1))
    else
        echo -e "  ${RED}❌ FAIL${NC} $label (expected exit=$expected, got $actual)"
        FAIL_COUNT=$((FAIL_COUNT+1))
    fi
}

echo -e "${YELLOW}=== DBMS Runner 통합 테스트 ===${NC}"

# ── 테스트 1: setup 동작 확인
echo "[T1] dbm setup"
OUT=$(./main.sh dbm setup 2>&1)
assert_contains "T1.1 setup 완료 메시지" "$OUT" "완료"
DIR_CHECK=$([ -d input/evidence/dbms/oracle ] && echo "OK" || echo "MISSING")
assert_contains "T1.2 input/evidence/dbms/oracle 생성" "$DIR_CHECK" "OK"

# ── 테스트 2: 유효한 profile audit (dry-run)
for PROF in cloud_dbms oracle mssql mysql postgresql altibase tibero; do
    echo "[T2.${PROF}] dbm audit --profile ${PROF} --dry-run"
    OUT=$(./main.sh dbm audit --profile "$PROF" --dry-run 2>&1)
    EXIT=$?
    assert_exit "T2.${PROF} 정상 종료" "$EXIT" 0
    assert_contains "T2.${PROF} 결과 요약" "$OUT" "결과 요약"
done

# ── 테스트 3: 단일 항목 실행
echo "[T3] dbm audit --profile oracle --check DBM-001 --dry-run"
OUT=$(./main.sh dbm audit --profile oracle --check DBM-001 --dry-run 2>&1)
EXIT=$?
assert_exit "T3.1 DBM-001 oracle 정상 종료" "$EXIT" 0
assert_contains "T3.2 DBM-001 언급" "$OUT" "DBM-001"

echo "[T3b] dbm audit --profile mssql --check DBM-030 --dry-run"
OUT=$(./main.sh dbm audit --profile mssql --check DBM-030 --dry-run 2>&1)
EXIT=$?
assert_exit "T3b.1 DBM-030 mssql 정상 종료" "$EXIT" 0

# ── 테스트 4: 없는 항목 → NOT_IMPLEMENTED
echo "[T4] dbm audit --profile oracle --check DBM-999 --dry-run"
OUT=$(./main.sh dbm audit --profile oracle --check DBM-999 --dry-run 2>&1)
assert_contains "T4 NOT_IMPLEMENTED" "$OUT" "NOT_IMPLEMENTED"

# ── 테스트 5: 잘못된 profile → ERROR
echo "[T5] dbm audit --profile wrong --dry-run"
OUT=$(./main.sh dbm audit --profile wrong --dry-run 2>&1)
EXIT=$?
assert_exit "T5.1 비정상 종료" "$EXIT" 1
assert_contains "T5.2 허용 profile 목록" "$OUT" "oracle"

# ── 테스트 6: --profile 없음 → ERROR
echo "[T6] dbm audit (no --profile)"
OUT=$(./main.sh dbm audit --dry-run 2>&1)
EXIT=$?
assert_exit "T6.1 비정상 종료" "$EXIT" 1
assert_contains "T6.2 --profile 필요 메시지" "$OUT" "profile"

# ── 테스트 7: MSSQL 비대상 항목 → NA
echo "[T7] DBM-030/031 in oracle → NA"
OUT=$(./main.sh dbm audit --profile oracle --dry-run 2>&1)
# NA 카운트 확인 (DBM-030, 031은 NA)
assert_contains "T7 NA 존재" "$OUT" "NA"

# ── 테스트 8: Phase 0 금지 옵션 차단
echo "[T8] --apply 옵션 차단"
OUT=$(./main.sh dbm audit --profile oracle --apply 2>&1)
EXIT=$?
assert_exit "T8 --apply 차단" "$EXIT" 1

echo ""
echo -e "${YELLOW}=== 결과 ===${NC}"
echo -e "  PASS: ${GREEN}${PASS_COUNT}${NC}"
echo -e "  FAIL: ${RED}${FAIL_COUNT}${NC}"
[[ "$FAIL_COUNT" -eq 0 ]] && exit 0 || exit 1

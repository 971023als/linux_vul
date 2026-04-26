#!/bin/bash
# tests/test_safety_guard.sh
# safety_guard.sh 단위 테스트

cd "$(dirname "${BASH_SOURCE[0]}")/.." || exit 1

PASS_COUNT=0; FAIL_COUNT=0
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; NC='\033[0m'
TMP_DIR=$(mktemp -d)
trap 'rm -rf "$TMP_DIR"' EXIT

assert_blocked() {
    local label="$1" script_content="$2"
    local f="${TMP_DIR}/test_blocked_$$.sh"
    echo "$script_content" > "$f"
    bash runners/safety_guard.sh "$f" > /dev/null 2>&1
    local exit_code=$?
    if [[ "$exit_code" -ne 0 ]]; then
        echo -e "  ${GREEN}✅ PASS${NC} [차단] $label"
        PASS_COUNT=$((PASS_COUNT+1))
    else
        echo -e "  ${RED}❌ FAIL${NC} [미차단] $label (차단되어야 함)"
        FAIL_COUNT=$((FAIL_COUNT+1))
    fi
}

assert_allowed() {
    local label="$1" script_content="$2"
    local f="${TMP_DIR}/test_allow_$$.sh"
    echo "$script_content" > "$f"
    bash runners/safety_guard.sh "$f" > /dev/null 2>&1
    local exit_code=$?
    if [[ "$exit_code" -eq 0 ]]; then
        echo -e "  ${GREEN}✅ PASS${NC} [허용] $label"
        PASS_COUNT=$((PASS_COUNT+1))
    else
        echo -e "  ${RED}❌ FAIL${NC} [오탐] $label (허용되어야 함)"
        FAIL_COUNT=$((FAIL_COUNT+1))
    fi
}

echo -e "${YELLOW}=== safety_guard 단위 테스트 ===${NC}"

# ── 차단 테스트
assert_blocked "sqlplus 직접 실행"     'sqlplus user/pass@db'
assert_blocked "sqlcmd 직접 실행"      'sqlcmd -S server -U user -P pass'
assert_blocked "mysql -u 직접 실행"    'mysql -u root -p database'
assert_blocked "psql 직접 실행"        'psql -h localhost -U user -d db'
assert_blocked "rm -rf 차단"           'rm -rf /var/log/db/'
assert_blocked "sed -i 차단"           'sed -i "s/foo/bar/" /etc/oracle.conf'
assert_blocked "chmod 777 차단"        'chmod 777 /data/oracle'
assert_blocked "lsnrctl stop 차단"     'lsnrctl stop LISTENER'
assert_blocked "systemctl restart 차단" 'systemctl restart oracle'
assert_blocked "xp_cmdshell exec 차단" 'sqlcmd -Q "EXEC xp_cmdshell'\''whoami'\''"'

# ── 허용 테스트 (오탐 방지 – 증적 파일 내용 grep)
assert_allowed "grep GRANT roles.txt"                'grep -i "GRANT" roles.txt'
assert_allowed "grep REVOKE audit_log.txt"           'grep -i "REVOKE" audit_log.txt'
assert_allowed "grep ALTER USER audit_log"           'grep -i "ALTER USER" audit_log.txt'
assert_allowed "grep xp_cmdshell 증적"               'grep -i "xp_cmdshell" xp_cmdshell_status.txt'
assert_allowed "cat roles.txt | grep DBA"            'cat roles.txt | grep -i "DBA"'
assert_allowed "awk on audit file"                   'awk -F: "{print \$1}" audit_config.txt'
assert_allowed "grep disabled xp_cmdshell"           'VALUE=$(grep -i "disabled" xp_cmdshell_status.txt)'
assert_allowed "주석 라인 내 sqlplus"                '# sqlplus user/pass@db'
assert_allowed "echo 문자열 저장 (DB client 아님)"   'echo "xp_cmdshell status check" > /tmp/note.txt'

echo ""
echo -e "${YELLOW}=== 결과 ===${NC}"
echo -e "  PASS: ${GREEN}${PASS_COUNT}${NC}"
echo -e "  FAIL: ${RED}${FAIL_COUNT}${NC}"
[[ "$FAIL_COUNT" -eq 0 ]] && exit 0 || exit 1

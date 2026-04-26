#!/bin/bash
# runners/safety_guard.sh
# -----------------------------------------------------------------------------
# [Safety Guard] audit 모드에서 위험 명령이 포함된 스크립트를 차단한다.
#
# 사용법:
#   safety_guard.sh <script_path>
#
# 반환:
#   exit 0: 안전 (실행 허용)
#   exit 1: 위험 명령 감지 (실행 차단) → stdout에 JSON 출력
#
# 핵심 원칙:
#   - grep/awk/sed/cat 등의 인자(증적 파일 내용)로 등장하는 SQL 키워드는 차단하지 않음
#   - DB client 실행 명령 자체, 또는 heredoc/pipe로 SQL을 DB client에 전달하는 행위를 차단
#   - 주석 라인(#으로 시작)은 검사 대상에서 제외
# -----------------------------------------------------------------------------

set -u

SCRIPT_PATH="${1:-}"

if [[ -z "$SCRIPT_PATH" ]]; then
    echo '{"status":"ERROR","reason":"safety_guard: script path not provided"}' >&2
    exit 1
fi

if [[ ! -f "$SCRIPT_PATH" ]]; then
    echo '{"status":"ERROR","reason":"safety_guard: script file not found"}' >&2
    exit 1
fi

# =============================================================================
# 주석 제거 + 유효 라인만 추출
# =============================================================================
EFFECTIVE_LINES=$(grep -v '^\s*#' "$SCRIPT_PATH" | grep -v '^\s*$')

UNSAFE_CMD=""
UNSAFE_REASON=""

# =============================================================================
# 패턴 1: DB client 직접 실행
# 컨텍스트: 명령어 자체로 실행되는 경우만 차단 (인자로 전달되는 문자열은 허용)
# =============================================================================
_check_db_client() {
    local pattern="$1"
    local label="$2"
    # 줄의 시작 또는 세미콜론/파이프 뒤에 DB client가 나오는 경우
    if echo "$EFFECTIVE_LINES" | grep -qiE "(^|[|;&\`\$(])\s*${pattern}"; then
        UNSAFE_CMD="$label"
        UNSAFE_REASON="DB client 직접 실행이 감지되었습니다"
        return 0
    fi
    return 1
}

_check_db_client 'sqlplus\s' 'sqlplus' && true
if [[ -n "$UNSAFE_CMD" ]]; then :; else
_check_db_client 'sqlcmd\s' 'sqlcmd' && true
fi
if [[ -n "$UNSAFE_CMD" ]]; then :; else
_check_db_client 'mysql\s+-[uU]' 'mysql -u' && true
fi
if [[ -n "$UNSAFE_CMD" ]]; then :; else
_check_db_client 'psql\s' 'psql' && true
fi
if [[ -n "$UNSAFE_CMD" ]]; then :; else
_check_db_client 'isql\s' 'isql' && true
fi
if [[ -n "$UNSAFE_CMD" ]]; then :; else
_check_db_client 'tbsql\s' 'tbSQL' && true
fi
if [[ -n "$UNSAFE_CMD" ]]; then :; else
_check_db_client 'tbSQL\s' 'tbSQL' && true
fi
if [[ -n "$UNSAFE_CMD" ]]; then :; else
_check_db_client '^aql\s' 'aql (Altibase)' && true
fi

# =============================================================================
# 패턴 2: SQL DDL/DML 실행 (heredoc, echo pipe 등을 통한 DB client 전달)
# 예: echo "ALTER USER ..." | sqlplus   /  sqlcmd -Q "EXEC xp_cmdshell"
# grep/cat/awk/sed 등의 인자로 등장하는 경우는 허용
# =============================================================================
_check_exec_sql() {
    local pattern="$1"
    local label="$2"
    # grep -i "GRANT" file.txt 같은 패턴 제외: grep/awk/sed/cat/echo의 인자 문자열 내부는 허용
    # 실제 실행 문맥: sqlplus/sqlcmd/mysql/psql 뒤에 오거나, -Q/-c/-e 옵션 뒤에 오거나, heredoc 내부에서
    # 단순 문자열 패턴 검색만으로는 판단 어려우므로 pipe to DB client 패턴에 집중
    if echo "$EFFECTIVE_LINES" | grep -qiP "${pattern}\s*\|?\s*(sqlplus|sqlcmd|mysql|psql|isql|tbSQL)"; then
        UNSAFE_CMD="$label"
        UNSAFE_REASON="SQL 실행 명령이 DB client에 파이프/전달되고 있습니다"
        return 0
    fi
    # -Q "-c" 옵션으로 직접 SQL 전달
    if echo "$EFFECTIVE_LINES" | grep -qiE "(sqlcmd\s+-Q|mysql\s+-[eE]|psql\s+-c|sqlplus\s+['\"].*${pattern})"; then
        UNSAFE_CMD="$label"
        UNSAFE_REASON="SQL 옵션을 통한 직접 실행이 감지되었습니다"
        return 0
    fi
    return 1
}

if [[ -z "$UNSAFE_CMD" ]]; then
    _check_exec_sql 'ALTER\s+USER' 'ALTER USER' && true
fi
if [[ -z "$UNSAFE_CMD" ]]; then
    _check_exec_sql 'ALTER\s+SYSTEM' 'ALTER SYSTEM' && true
fi
if [[ -z "$UNSAFE_CMD" ]]; then
    _check_exec_sql 'ALTER\s+DATABASE' 'ALTER DATABASE' && true
fi
if [[ -z "$UNSAFE_CMD" ]]; then
    _check_exec_sql 'CREATE\s+USER' 'CREATE USER' && true
fi
if [[ -z "$UNSAFE_CMD" ]]; then
    _check_exec_sql 'DROP\s+USER' 'DROP USER' && true
fi
if [[ -z "$UNSAFE_CMD" ]]; then
    _check_exec_sql 'DROP\s+DATABASE' 'DROP DATABASE' && true
fi
if [[ -z "$UNSAFE_CMD" ]]; then
    _check_exec_sql 'DROP\s+TABLE' 'DROP TABLE' && true
fi
if [[ -z "$UNSAFE_CMD" ]]; then
    _check_exec_sql 'TRUNCATE\s+TABLE' 'TRUNCATE TABLE' && true
fi
if [[ -z "$UNSAFE_CMD" ]]; then
    _check_exec_sql 'DELETE\s+FROM' 'DELETE FROM' && true
fi
if [[ -z "$UNSAFE_CMD" ]]; then
    _check_exec_sql 'INSERT\s+INTO' 'INSERT INTO' && true
fi

# =============================================================================
# 패턴 3: 위험 시스템 명령 (조건 없이 금지)
# =============================================================================
_check_dangerous_cmd() {
    local pattern="$1"
    local label="$2"
    if echo "$EFFECTIVE_LINES" | grep -qiE "$pattern"; then
        UNSAFE_CMD="$label"
        UNSAFE_REASON="위험 시스템 명령이 감지되었습니다"
        return 0
    fi
    return 1
}

if [[ -z "$UNSAFE_CMD" ]]; then
    _check_dangerous_cmd '(^|\s)rm\s+-rf' 'rm -rf' && true
fi
if [[ -z "$UNSAFE_CMD" ]]; then
    _check_dangerous_cmd 'sed\s+-i' 'sed -i' && true
fi
if [[ -z "$UNSAFE_CMD" ]]; then
    _check_dangerous_cmd 'chmod\s+777' 'chmod 777' && true
fi
if [[ -z "$UNSAFE_CMD" ]]; then
    _check_dangerous_cmd 'lsnrctl\s+(stop|start|reload)' 'lsnrctl stop/start' && true
fi
if [[ -z "$UNSAFE_CMD" ]]; then
    _check_dangerous_cmd 'systemctl\s+(restart|stop)\s+(oracle|mssql|mysql|postgres|altibase|tibero)' 'systemctl restart/stop DBMS' && true
fi
if [[ -z "$UNSAFE_CMD" ]]; then
    _check_dangerous_cmd 'service\s+\S+\s+(restart|stop)' 'service restart/stop' && true
fi

# =============================================================================
# 패턴 4: xp_cmdshell / sp_configure 실행 (SQL 컨텍스트 내)
# (grep으로 증적 파일에서 읽는 건 허용 – 실행 컨텍스트만 차단)
# =============================================================================
if [[ -z "$UNSAFE_CMD" ]]; then
    if echo "$EFFECTIVE_LINES" | grep -qiE "(sqlcmd|mssql|osql).*xp_cmdshell|xp_cmdshell.*exec|EXEC\s+xp_cmdshell"; then
        UNSAFE_CMD="xp_cmdshell 실행"
        UNSAFE_REASON="xp_cmdshell 실행 시도가 감지되었습니다"
    fi
fi
if [[ -z "$UNSAFE_CMD" ]]; then
    if echo "$EFFECTIVE_LINES" | grep -qiE "(sqlcmd|mssql|osql).*sp_configure|sp_configure\s+'xp_cmdshell'"; then
        UNSAFE_CMD="sp_configure"
        UNSAFE_REASON="sp_configure 실행 시도가 감지되었습니다"
    fi
fi

# =============================================================================
# 결과 출력
# =============================================================================
if [[ -n "$UNSAFE_CMD" ]]; then
    python3 -c "
import json, sys
print(json.dumps({
    'status': 'ERROR',
    'reason': 'Unsafe DBMS command detected in audit mode',
    'unsafe_command': sys.argv[1],
    'unsafe_reason': sys.argv[2],
    'audit_only': True
}, ensure_ascii=False))
" "$UNSAFE_CMD" "$UNSAFE_REASON"
    exit 1
fi

# 안전
exit 0

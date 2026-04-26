#!/bin/bash
# runners/evidence_collector.sh
# -----------------------------------------------------------------------------
# [Evidence Collector] 항목별 증적 디렉터리 생성, 실행 정보 저장, manifest 갱신
#
# 사용법:
#   evidence_collector.sh \
#       --check-id   DBM-001 \
#       --profile    oracle \
#       --script     shell_script/dbms/oracle/DBM-001.sh \
#       --stdout     /path/to/stdout.txt \
#       --stderr     /path/to/stderr.txt \
#       --exit-code  0 \
#       --input-dir  input/evidence/dbms/oracle \
#       --output-dir output/evidence/dbms/oracle/DBM-001
# -----------------------------------------------------------------------------

set -u

CHECK_ID=""
PROFILE=""
SCRIPT_PATH=""
STDOUT_FILE=""
STDERR_FILE=""
EXIT_CODE=0
INPUT_DIR=""
OUTPUT_DIR=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        --check-id)   CHECK_ID="${2:-}";    shift 2 ;;
        --profile)    PROFILE="${2:-}";     shift 2 ;;
        --script)     SCRIPT_PATH="${2:-}"; shift 2 ;;
        --stdout)     STDOUT_FILE="${2:-}"; shift 2 ;;
        --stderr)     STDERR_FILE="${2:-}"; shift 2 ;;
        --exit-code)  EXIT_CODE="${2:-0}";  shift 2 ;;
        --input-dir)  INPUT_DIR="${2:-}";   shift 2 ;;
        --output-dir) OUTPUT_DIR="${2:-}";  shift 2 ;;
        *) shift ;;
    esac
done

if [[ -z "$OUTPUT_DIR" ]]; then
    echo "[evidence_collector] ERROR: --output-dir 필요" >&2
    exit 1
fi

mkdir -p "$OUTPUT_DIR"

# ------------------------------------------------------------------
# 민감정보 마스킹 함수
# ------------------------------------------------------------------
_mask_sensitive() {
    local text="$1"
    # IP 주소 마스킹 (마지막 옥텟)
    text=$(echo "$text" | sed -E 's/([0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3})\.[0-9]{1,3}/\1.xxx/g')
    # Password/Secret 값 마스킹
    text=$(echo "$text" | sed -E 's/(password|passwd|pwd|secret|token|key)\s*[=:]\s*\S+/\1=***MASKED***/gi')
    # JDBC URL 마스킹
    text=$(echo "$text" | sed -E 's|jdbc:[a-z]+://[^[:space:]]+|jdbc:***MASKED***|gi')
    # 주민등록번호 패턴
    text=$(echo "$text" | sed -E 's/[0-9]{6}-[0-9]{7}/XXXXXX-XXXXXXX/g')
    # 계좌번호 (숫자-숫자 패턴)
    text=$(echo "$text" | sed -E 's/[0-9]{3,6}-[0-9]{2,6}-[0-9]{4,8}/***ACCOUNT***/g')
    echo "$text"
}

TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# ------------------------------------------------------------------
# stdout 저장 (마스킹)
# ------------------------------------------------------------------
if [[ -f "$STDOUT_FILE" ]]; then
    _mask_sensitive "$(cat "$STDOUT_FILE")" > "${OUTPUT_DIR}/stdout.txt"
else
    echo "" > "${OUTPUT_DIR}/stdout.txt"
fi

# ------------------------------------------------------------------
# stderr 저장 (마스킹)
# ------------------------------------------------------------------
if [[ -f "$STDERR_FILE" ]]; then
    _mask_sensitive "$(cat "$STDERR_FILE")" > "${OUTPUT_DIR}/stderr.txt"
else
    echo "" > "${OUTPUT_DIR}/stderr.txt"
fi

# ------------------------------------------------------------------
# exit code 저장
# ------------------------------------------------------------------
echo "$EXIT_CODE" > "${OUTPUT_DIR}/exit_code.txt"

# ------------------------------------------------------------------
# 입력 증적 파일 목록 기록
# ------------------------------------------------------------------
INPUT_FILES_JSON="[]"
if [[ -d "$INPUT_DIR" ]]; then
    INPUT_FILES_JSON=$(python3 -c "
import os, json
d = '$INPUT_DIR'
files = []
if os.path.isdir(d):
    for fn in sorted(os.listdir(d)):
        fp = os.path.join(d, fn)
        if os.path.isfile(fp):
            size = os.path.getsize(fp)
            real_lines = 0
            try:
                with open(fp) as f:
                    for line in f:
                        s = line.strip()
                        if s and not s.startswith('#'):
                            real_lines += 1
            except:
                pass
            files.append({'file': fn, 'size': size, 'valid_evidence': size > 0 and real_lines > 0})
print(json.dumps(files, ensure_ascii=False))
" 2>/dev/null || echo "[]")
fi

# ------------------------------------------------------------------
# raw_result.json 저장
# ------------------------------------------------------------------
python3 -c "
import json, sys
data = {
    'check_id': '$CHECK_ID',
    'profile': '$PROFILE',
    'script': '$SCRIPT_PATH',
    'timestamp': '$TIMESTAMP',
    'exit_code': int('$EXIT_CODE'),
    'input_dir': '$INPUT_DIR',
    'output_dir': '$OUTPUT_DIR',
    'input_files': $INPUT_FILES_JSON
}
with open('${OUTPUT_DIR}/raw_result.json', 'w') as f:
    json.dump(data, f, ensure_ascii=False, indent=2)
print('raw_result.json written')
" 2>/dev/null

# ------------------------------------------------------------------
# 전체 evidence manifest 갱신
# ------------------------------------------------------------------
MANIFEST_DIR="output/evidence/dbms"
MANIFEST_FILE="${MANIFEST_DIR}/evidence_manifest.json"
mkdir -p "$MANIFEST_DIR"

python3 - << PYEOF
import json, os
manifest_file = "$MANIFEST_FILE"
entry = {
    "check_id": "$CHECK_ID",
    "profile": "$PROFILE",
    "timestamp": "$TIMESTAMP",
    "script": "$SCRIPT_PATH",
    "output_dir": "$OUTPUT_DIR",
    "exit_code": int("$EXIT_CODE"),
    "input_files": $INPUT_FILES_JSON
}

# 기존 manifest 로드
manifest = []
if os.path.isfile(manifest_file):
    try:
        with open(manifest_file) as f:
            manifest = json.load(f)
    except:
        manifest = []

# 동일 check_id+profile 항목 교체 또는 추가
found = False
for i, e in enumerate(manifest):
    if e.get("check_id") == entry["check_id"] and e.get("profile") == entry["profile"]:
        manifest[i] = entry
        found = True
        break
if not found:
    manifest.append(entry)

with open(manifest_file, "w") as f:
    json.dump(manifest, f, ensure_ascii=False, indent=2)
print(f"manifest updated: {manifest_file} ({len(manifest)} entries)")
PYEOF

exit 0

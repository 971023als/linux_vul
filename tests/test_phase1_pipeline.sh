#!/bin/bash
# tests/test_phase1_pipeline.sh
# Purpose: Verify Phase 1 Normalization pipeline with mock evidence

echo "=== Phase 1 Pipeline Verification Start ==="

# 1. Clean up old data
rm -rf output/evidence/U-*
rm -f output/json/normalized_result.json

# 2. Generate Mock Evidence
echo "[1/3] Generating Mock Evidence..."

# Case 1: PASS (Standard)
mkdir -p output/evidence/U-01
echo "root 계정 원격 접속 제한이 설정되어 있어 양호합니다." > output/evidence/U-01/stdout.txt
echo "" > output/evidence/U-01/stderr.txt
echo "0" > output/evidence/U-01/exit_code.txt

# Case 2: FAIL (Standard)
mkdir -p output/evidence/U-02
echo "패스워드 복잡성 설정이 되어 있지 않아 취약합니다." > output/evidence/U-02/stdout.txt
echo "" > output/evidence/U-02/stderr.txt
echo "0" > output/evidence/U-02/exit_code.txt

# Case 3: PASS (Complex Regex - Negation)
mkdir -p output/evidence/U-03
echo "점검 결과 보안상 어떠한 문제도 없음이 확인되었습니다." > output/evidence/U-03/stdout.txt
echo "" > output/evidence/U-03/stderr.txt
echo "0" > output/evidence/U-03/exit_code.txt

# Case 4: EVIDENCE_MISSING (Empty file)
mkdir -p output/evidence/U-04
touch output/evidence/U-04/stdout.txt
echo "" > output/evidence/U-04/stderr.txt
echo "0" > output/evidence/U-04/exit_code.txt

# Case 5: ERROR (Non-zero exit code)
mkdir -p output/evidence/U-05
echo "명령어를 찾을 수 없습니다." > output/evidence/U-05/stdout.txt
echo "bash: command not found" > output/evidence/U-05/stderr.txt
echo "127" > output/evidence/U-05/exit_code.txt

# Case 6: MANUAL_REVIEW (Keyword match)
mkdir -p output/evidence/U-06
echo "해당 항목은 수동점검이 필요합니다." > output/evidence/U-06/stdout.txt
echo "" > output/evidence/U-06/stderr.txt
echo "0" > output/evidence/U-06/exit_code.txt

echo "Mock evidence generated in output/evidence/"

# 3. Run Normalizer via main.sh
echo "[2/3] Running Normalizer..."
bash main.sh normalize

# 4. Verify Results
echo "[3/3] Verifying normalized_result.json..."
if [ -f "output/json/normalized_result.json" ]; then
    echo "SUCCESS: normalized_result.json created."
    
    # Check some statuses using grep or python
    python3 -c "
import json
with open('output/json/normalized_result.json', 'r', encoding='utf-8') as f:
    data = json.load(f)
    results = {r['id']: r['status'] for r in data['results']}
    print(f\"U-01: {results.get('U-01')}\")
    print(f\"U-02: {results.get('U-02')}\")
    print(f\"U-03: {results.get('U-03')}\")
    print(f\"U-04: {results.get('U-04')}\")
    print(f\"U-05: {results.get('U-05')}\")
    print(f\"U-06: {results.get('U-06')}\")
"
fi

# 5. Run Phase 2 Reporting
echo "[4/4] Running Phase 2 Reporting (CSV, HTML)..."
bash main.sh csv
bash main.sh report

# 6. Final Result Check
echo "=== Final Result Check ==="
ls -l output/csv/results_*.csv
ls -l output/html/report_*.html

if [ -f "output/json/normalized_result.json" ] && [ -n "$(ls output/html/report_*.html 2>/dev/null)" ]; then
    echo "SUCCESS: Full Pipeline (Audit -> Normalize -> Report) Verified."
else
    echo "FAILURE: Pipeline broken."
    exit 1
fi

echo "=== Phase 1 & 2 Pipeline Verification Finished ==="

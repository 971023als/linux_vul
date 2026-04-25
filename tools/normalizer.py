#!/usr/bin/env python3
"""
tools/normalizer.py — Phase 1: 결과 상태값 표준화(Normalization) 파이프라인

SPEC: Phase1_Normalization_Spec.md

디버깅: --debug 플래그 또는 DEBUG=1 환경변수
"""

import argparse
import json
import logging
import os
import re
import sys
import time
from datetime import datetime
from pathlib import Path

# =============================================================================
# 디버그 로거 설정 (--debug 파싱 전 기본 구성)
# =============================================================================
_log = logging.getLogger("normalizer")

def _setup_logging(debug: bool) -> None:
    level = logging.DEBUG if debug else logging.WARNING
    fmt   = "[%(levelname)s %(asctime)s.%(msecs)03d][normalizer] %(message)s"
    logging.basicConfig(level=level, format=fmt, datefmt="%H:%M:%S", stream=sys.stderr)
    _log.setLevel(level)
    if debug:
        _log.debug("디버그 모드 활성화 — logging.DEBUG")

# =============================================================================
# Phase 1 §1: 표준 상태값
# =============================================================================
STATUS_PASS             = "PASS"
STATUS_FAIL             = "FAIL"
STATUS_NA               = "NA"
STATUS_MANUAL_REVIEW    = "MANUAL_REVIEW"
STATUS_EVIDENCE_MISSING = "EVIDENCE_MISSING"
STATUS_ERROR            = "ERROR"
STATUS_NOT_IMPLEMENTED  = "NOT_IMPLEMENTED"

# =============================================================================
# Phase 1 §3: 상태 매핑 패턴
# =============================================================================
PASS_PATTERNS    = re.compile(r"양호|안전|PASS|Pass|OK|Good|정상|적절|충족|활성화|설정됨|사용 중|실행 중", re.IGNORECASE)
# NOTE: '없음'은 FAIL 패턴에서 제외. "파일 없음", "문제 없음", "취약한 서비스 없음" 등
# 양호를 의미하는 문장에서 오분류를 유발함. 대신 아래 복합 패턴으로 선제 처리.
FAIL_PATTERNS    = re.compile(r"취약|위험|FAIL|Fail|Vulnerable|미설정|비활성|허용|노출|불일치", re.IGNORECASE)
# 부정 표현: FAIL 키워드 + "없음" 조합 → 실제 양호
# 예) "문제 없음", "취약한 서비스 없음", "취약점이 없음", "위험이 없음"
NEGATED_FAIL_PATTERNS = re.compile(
    r"(문제|취약|위험|오류|결함|취약점|취약한\s*\S+)\s*(이|가|은|는)?\s*없음"
    r"|없음.*?(문제|취약|위험)",
    re.IGNORECASE,
)
# 역부정 표현: PASS 키워드 + "없음" 조합 → 실제 취약
# 예) "설정됨 없음"(미설정), "활성화 없음"(비활성)
NEGATED_PASS_PATTERNS = re.compile(
    r"(설정됨|활성화|실행\s*중|사용\s*중)\s*(이|가|은|는)?\s*없음",
    re.IGNORECASE,
)
NA_PATTERNS      = re.compile(r"해당없음|해당 없음|N/A|Not Applicable|NA|적용불가", re.IGNORECASE)
MANUAL_PATTERNS  = re.compile(r"수동점검|수동 점검|확인필요|확인 필요|Manual Review|Manual_Review|MANUAL", re.IGNORECASE)
NOT_IMPL_PATTERNS= re.compile(r"NOT_IMPLEMENTED|미구현", re.IGNORECASE)
ERROR_PATTERNS   = re.compile(r"ERROR|Exception|Traceback|command not found|Permission denied", re.IGNORECASE)

# =============================================================================
# ISMS-P / 전자금융감독규정 컴플라이언스 매핑
# =============================================================================
COMPLIANCE_MAP = {
    **{f"U-{i:02d}": {
        "category": "계정 관리",
        "isms_p": "2.4.3 (인증 및 권한 부여), 2.4.7 (원격접근 통제)",
        "financial_reg": "전자금융감독규정 제13조, 제15조"
    } for i in range(1, 23)},
    **{f"U-{i:02d}": {
        "category": "파일 및 디렉터리 관리",
        "isms_p": "2.6.1 (시스템 하드닝)",
        "financial_reg": "전자금융감독규정 제13조 (비밀보호)"
    } for i in range(23, 37)},
    **{f"U-{i:02d}": {
        "category": "서비스 관리",
        "isms_p": "2.6.1 (시스템 하드닝)",
        "financial_reg": "전자금융감독규정 제15조 (서비스 제거)"
    } for i in range(37, 61)},
    **{f"U-{i:02d}": {
        "category": "로그 및 패치 관리",
        "isms_p": "2.10.1 (로깅 및 감시), 2.6.2 (패치 관리)",
        "financial_reg": "전자금융감독규정 제13조 (접속기록)"
    } for i in range(61, 73)},
}

# =============================================================================
# Phase 1 §2: 증적 유효성 검사
# =============================================================================
def validate_evidence(evidence_dir: Path, check_id: str) -> dict:
    item_dir       = evidence_dir / check_id
    stdout_file    = item_dir / "stdout.txt"
    stderr_file    = item_dir / "stderr.txt"
    exit_code_file = item_dir / "exit_code.txt"

    _log.debug("validate_evidence: check=%s  item_dir=%s", check_id, item_dir)

    result = {
        "valid": True,
        "status_override": None,
        "stdout": "",
        "exit_code": 0,
        "stderr": "",
    }

    # Step 1: 존재 여부
    _log.debug("  Step1 Existence: dir_exists=%s  stdout_exists=%s",
               item_dir.exists(), stdout_file.exists())
    if not item_dir.exists() or not stdout_file.exists():
        _log.debug("  → EVIDENCE_MISSING (디렉터리 또는 stdout 없음)")
        result["valid"] = False
        result["status_override"] = STATUS_EVIDENCE_MISSING
        return result

    # Step 2: 크기 체크
    stdout_size = stdout_file.stat().st_size
    _log.debug("  Step2 Size: stdout=%d bytes", stdout_size)
    if stdout_size == 0:
        _log.debug("  → EVIDENCE_MISSING (stdout 0 bytes)")
        result["valid"] = False
        result["status_override"] = STATUS_EVIDENCE_MISSING
        result["stderr"] = "[HARNESS] stdout is 0 bytes"
        return result

    # 파일 읽기
    result["stdout"] = stdout_file.read_text(encoding="utf-8", errors="replace").strip()
    if stderr_file.exists():
        result["stderr"] = stderr_file.read_text(encoding="utf-8", errors="replace").strip()
    if exit_code_file.exists():
        try:
            result["exit_code"] = int(exit_code_file.read_text().strip())
        except ValueError:
            result["exit_code"] = -1
            _log.debug("  exit_code 파싱 실패 → -1")

    _log.debug("  파일 읽기 완료: stdout=%d chars  stderr=%d chars  exit_code=%d",
               len(result["stdout"]), len(result["stderr"]), result["exit_code"])

    # Step 3: exit code
    _log.debug("  Step3 ExitCode: %d", result["exit_code"])
    if result["exit_code"] != 0:
        _log.debug("  → ERROR (exit_code=%d)", result["exit_code"])
        result["valid"] = False
        result["status_override"] = STATUS_ERROR
        return result

    # Step 4: 최소 길이
    _log.debug("  Step4 MinLength: %d chars", len(result["stdout"]))
    if len(result["stdout"]) < 3:
        _log.debug("  → MANUAL_REVIEW (출력이 너무 짧음)")
        result["valid"] = False
        result["status_override"] = STATUS_MANUAL_REVIEW
        result["stderr"] += " [HARNESS] Output too short for reliable parsing"
        return result

    _log.debug("  → Integrity OK")
    return result


# =============================================================================
# Phase 1 §3: 상태 매핑
# =============================================================================
def map_status(stdout: str) -> str:
    _log.debug("map_status: 입력 %d chars  첫50자=%r", len(stdout), stdout[:50])

    if NOT_IMPL_PATTERNS.search(stdout):
        _log.debug("  → NOT_IMPLEMENTED 패턴 매치")
        return STATUS_NOT_IMPLEMENTED
    if NA_PATTERNS.search(stdout):
        _log.debug("  → NA 패턴 매치")
        return STATUS_NA
    if MANUAL_PATTERNS.search(stdout):
        _log.debug("  → MANUAL_REVIEW 패턴 매치")
        return STATUS_MANUAL_REVIEW
    if ERROR_PATTERNS.search(stdout):
        _log.debug("  → ERROR 패턴 매치")
        return STATUS_ERROR
    # 복합 패턴 선제 체크 (단순 키워드 매치보다 우선)
    # "문제 없음", "취약한 서비스 없음" 등 부정 표현 → PASS
    if NEGATED_FAIL_PATTERNS.search(stdout):
        _log.debug("  → NEGATED_FAIL 패턴 매치 (부정 표현 → PASS)")
        return STATUS_PASS
    # "설정됨 없음", "활성화 없음" 등 역부정 표현 → FAIL
    if NEGATED_PASS_PATTERNS.search(stdout):
        _log.debug("  → NEGATED_PASS 패턴 매치 (역부정 표현 → FAIL)")
        return STATUS_FAIL
    if FAIL_PATTERNS.search(stdout):
        _log.debug("  → FAIL 패턴 매치")
        return STATUS_FAIL
    if PASS_PATTERNS.search(stdout):
        _log.debug("  → PASS 패턴 매치")
        return STATUS_PASS

    _log.debug("  → 패턴 없음 → MANUAL_REVIEW")
    return STATUS_MANUAL_REVIEW


# =============================================================================
# 데이터 마스킹
# =============================================================================
def mask_sensitive(text: str) -> str:
    original_len = len(text)
    text = re.sub(r'\b(\d{1,3})\.(\d{1,3})\.(\d{1,3})\.\d{1,3}\b', r'\1.\2.\3.***', text)
    text = re.sub(r'\$[156]\$[^\s:]+', '***MASKED_HASH***', text)
    text = re.sub(r'uid=\d+\([^)]+\)', 'uid=***', text)
    if len(text) != original_len:
        _log.debug("mask_sensitive: 마스킹 적용 (%d → %d chars)", original_len, len(text))
    return text


# =============================================================================
# Phase 1 §4: 정규화 파이프라인
# =============================================================================
def run_normalization(evidence_dir: Path, output_path: Path) -> dict:
    _log.debug("run_normalization 시작: evidence_dir=%s  output=%s", evidence_dir, output_path)

    # evidence 디렉터리 내 체크 항목 확인
    existing_checks = sorted([d.name for d in evidence_dir.iterdir() if d.is_dir()]) if evidence_dir.exists() else []
    _log.debug("evidence 디렉터리 내 항목: %d 개 → %s", len(existing_checks), existing_checks[:5])

    results = []
    summary = {
        STATUS_PASS: 0, STATUS_FAIL: 0, STATUS_NA: 0,
        STATUS_MANUAL_REVIEW: 0, STATUS_EVIDENCE_MISSING: 0,
        STATUS_ERROR: 0, STATUS_NOT_IMPLEMENTED: 0,
    }

    pipeline_start = time.perf_counter()

    for i in range(1, 73):
        check_id   = f"U-{i:02d}"
        compliance = COMPLIANCE_MAP.get(check_id, {
            "category": "기타", "isms_p": "N/A", "financial_reg": "N/A",
        })
        _log.debug("─── %s 처리 시작 (category=%s)", check_id, compliance["category"])

        t0 = time.perf_counter()

        # Integrity Validation
        ev = validate_evidence(evidence_dir, check_id)

        if ev["status_override"] is not None:
            final_status = ev["status_override"]
            raw_output   = ev.get("stdout", "")
            detail       = ev.get("stderr", "")
            _log.debug("%s: status_override=%s (integrity 실패)", check_id, final_status)
        else:
            final_status = map_status(ev["stdout"])
            raw_output   = mask_sensitive(ev["stdout"])
            detail       = mask_sensitive(ev["stderr"]) if ev["stderr"] else ""
            _log.debug("%s: 상태 매핑 결과=%s", check_id, final_status)

        summary[final_status] = summary.get(final_status, 0) + 1
        t1 = time.perf_counter()
        _log.debug("%s: 처리 완료 → %s  elapsed=%.1fms", check_id, final_status, (t1-t0)*1000)

        record = {
            "id": check_id, "category": compliance["category"],
            "status": final_status,
            "isms_p": compliance["isms_p"], "financial_reg": compliance["financial_reg"],
            "exit_code": ev.get("exit_code", 0),
            "detail": detail, "raw_output": raw_output,
        }
        results.append(record)

        icon = "✓" if final_status == STATUS_PASS else ("✗" if final_status == STATUS_FAIL else "~")
        print(f"  [{icon}] {check_id}: {final_status}")

    # JSON Export
    _log.debug("JSON 직렬화 시작: %d 개 결과", len(results))
    output_path.parent.mkdir(parents=True, exist_ok=True)
    normalized = {
        "meta": {
            "generated_at": datetime.now().isoformat(),
            "total": len(results),
            "summary": summary,
        },
        "results": results,
    }
    json_str = json.dumps(normalized, ensure_ascii=False, indent=2)
    output_path.write_text(json_str, encoding="utf-8")

    pipeline_elapsed = (time.perf_counter() - pipeline_start) * 1000
    _log.debug("JSON 저장 완료: %s  크기=%d bytes  총소요=%.0fms",
               output_path, len(json_str), pipeline_elapsed)
    _log.debug("Summary: %s", summary)

    return normalized


# =============================================================================
# Entrypoint
# =============================================================================
def main():
    parser = argparse.ArgumentParser(
        description="Phase 1: Normalize vulnerability evidence to standard statuses"
    )
    parser.add_argument("--evidence-dir", required=True, help="Path to output/evidence/ directory")
    parser.add_argument("--output",       required=True, help="Output JSON path")
    parser.add_argument("--debug", action="store_true",
                        default=(os.environ.get("DEBUG", "0") != "0"),
                        help="디버그 로그 출력 (환경변수 DEBUG=1 도 가능)")
    args = parser.parse_args()

    _setup_logging(args.debug)

    evidence_dir = Path(args.evidence_dir)
    output_path  = Path(args.output)

    _log.debug("main: evidence_dir=%s  output=%s", evidence_dir, output_path)

    if not evidence_dir.exists():
        print(f"[ERROR] Evidence directory not found: {evidence_dir}", file=sys.stderr)
        sys.exit(1)

    print(f"[Normalizer] Evidence dir : {evidence_dir}")
    print(f"[Normalizer] Output       : {output_path}")
    if args.debug:
        print(f"[Normalizer] DEBUG 모드 활성화 (stderr 출력)", file=sys.stderr)
    print("")

    t_start = time.perf_counter()
    result = run_normalization(evidence_dir, output_path)
    t_end = time.perf_counter()

    print("")
    print("=== Summary ===")
    for status, count in result["meta"]["summary"].items():
        if count > 0:
            print(f"  {status:<20}: {count}")
    print(f"  {'TOTAL':<20}: {result['meta']['total']}")
    print(f"\nNormalized result saved: {output_path}")
    _log.debug("main 완료: 총소요=%.0fms", (t_end - t_start) * 1000)


if __name__ == "__main__":
    main()

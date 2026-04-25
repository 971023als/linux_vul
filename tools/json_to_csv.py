#!/usr/bin/env python3
"""
tools/json_to_csv.py — JSON → CSV 변환
normalized_result.json → output/csv/results_날짜.csv

디버깅: --debug 플래그 또는 DEBUG=1 환경변수
"""
import argparse
import csv
import json
import logging
import os
import sys
import time
from pathlib import Path

_log = logging.getLogger("json_to_csv")

def _setup_logging(debug: bool) -> None:
    level = logging.DEBUG if debug else logging.WARNING
    fmt   = "[%(levelname)s %(asctime)s.%(msecs)03d][json_to_csv] %(message)s"
    logging.basicConfig(level=level, format=fmt, datefmt="%H:%M:%S", stream=sys.stderr)
    _log.setLevel(level)
    if debug:
        _log.debug("디버그 모드 활성화")


def convert(input_path: Path, output_path: Path) -> None:
    _log.debug("convert 시작: input=%s", input_path)

    t0 = time.perf_counter()
    raw = input_path.read_text(encoding="utf-8")
    _log.debug("파일 읽기 완료: %d bytes  elapsed=%.1fms", len(raw), (time.perf_counter()-t0)*1000)

    data    = json.loads(raw)
    results = data.get("results", [])
    meta    = data.get("meta", {})

    _log.debug("JSON 파싱 완료: results=%d  meta=%s", len(results), meta)

    if not results:
        _log.debug("결과 없음 → 종료")
        print("[json_to_csv] No results to convert.", file=sys.stderr)
        sys.exit(1)

    # 상태별 카운트 디버그 출력
    if _log.isEnabledFor(logging.DEBUG):
        from collections import Counter
        status_counts = Counter(r.get("status") for r in results)
        _log.debug("상태 분포: %s", dict(status_counts))

    fieldnames = ["id", "category", "status",
                  "isms_p", "financial_reg",
                  "exit_code", "detail", "raw_output"]

    output_path.parent.mkdir(parents=True, exist_ok=True)
    _log.debug("출력 경로 준비: %s", output_path)

    t1 = time.perf_counter()
    with output_path.open("w", newline="", encoding="utf-8-sig") as f:
        writer = csv.DictWriter(f, fieldnames=fieldnames, extrasaction="ignore")
        writer.writeheader()
        written = 0
        for row in results:
            writer.writerow(row)
            written += 1
            if written % 20 == 0:
                _log.debug("  진행: %d/%d 행 기록", written, len(results))

    csv_size = output_path.stat().st_size
    elapsed  = (time.perf_counter() - t1) * 1000
    _log.debug("CSV 쓰기 완료: %d 행  크기=%d bytes  elapsed=%.1fms",
               written, csv_size, elapsed)

    print(f"[json_to_csv] {len(results)} rows → {output_path}")


def main() -> None:
    parser = argparse.ArgumentParser(description="Convert normalized JSON to CSV")
    parser.add_argument("--input",  required=True, help="normalized_result.json path")
    parser.add_argument("--output", required=True, help="Output CSV path")
    parser.add_argument("--debug", action="store_true",
                        default=(os.environ.get("DEBUG", "0") != "0"),
                        help="디버그 로그 출력 (환경변수 DEBUG=1 도 가능)")
    args = parser.parse_args()

    _setup_logging(args.debug)

    input_path  = Path(args.input)
    output_path = Path(args.output)

    _log.debug("main: input=%s  output=%s", input_path, output_path)

    if not input_path.exists():
        print(f"[ERROR] Input not found: {input_path}", file=sys.stderr)
        sys.exit(1)

    _log.debug("input 크기: %d bytes", input_path.stat().st_size)

    t_start = time.perf_counter()
    convert(input_path, output_path)
    _log.debug("main 완료: 총소요=%.0fms", (time.perf_counter() - t_start) * 1000)


if __name__ == "__main__":
    main()

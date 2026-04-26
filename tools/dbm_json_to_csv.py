#!/usr/bin/env python3
"""
tools/dbm_json_to_csv.py
DBMS 진단 결과 JSON → CSV 변환 (UTF-8-SIG, Excel 한글 지원)
"""
import json, csv, os, shutil
from datetime import datetime

PROJECT_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
JSON_LATEST = os.path.join(PROJECT_DIR, "output", "json", "dbms_assessment_result.json")
CSV_DIR = os.path.join(PROJECT_DIR, "output", "csv")

FIELDNAMES = [
    "assessment_id", "profile", "id", "source_id", "title",
    "risk_level", "severity_label", "status", "reason",
    "script_path", "exit_code", "evidence_count",
    "description", "recommendation", "error_message"
]


def load_results(json_path: str) -> dict:
    if not os.path.isfile(json_path):
        return {}
    with open(json_path, encoding="utf-8") as f:
        return json.load(f)


def flatten(data: dict) -> list[dict]:
    rows = []
    assessment_id = data.get("assessment_id", "")
    profile = data.get("target", {}).get("profile", "")
    for r in data.get("results", []):
        script = r.get("script", {})
        rows.append({
            "assessment_id": assessment_id,
            "profile": profile,
            "id": r.get("id", ""),
            "source_id": r.get("source_id", ""),
            "title": r.get("title", ""),
            "risk_level": r.get("risk_level", ""),
            "severity_label": r.get("severity_label", ""),
            "status": r.get("status", ""),
            "reason": r.get("reason", ""),
            "script_path": script.get("path", ""),
            "exit_code": script.get("exit_code", ""),
            "evidence_count": len(r.get("evidence", [])),
            "description": r.get("description", ""),
            "recommendation": r.get("recommendation", ""),
            "error_message": r.get("error_message") or "",
        })
    return rows


def write_csv(rows: list[dict], path: str):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, "w", newline="", encoding="utf-8-sig") as f:
        w = csv.DictWriter(f, fieldnames=FIELDNAMES, extrasaction="ignore")
        w.writeheader()
        for row in rows:
            w.writerow(row)
    print(f"[dbm_json_to_csv] CSV 저장: {path} ({len(rows)} rows)")


def main():
    os.makedirs(CSV_DIR, exist_ok=True)
    data = load_results(JSON_LATEST)
    rows = flatten(data)

    ts = datetime.now().strftime("%Y%m%d_%H%M%S")
    ts_path = os.path.join(CSV_DIR, f"dbms_assessment_result_{ts}.csv")
    latest_path = os.path.join(CSV_DIR, "dbms_assessment_result.csv")

    write_csv(rows, ts_path)
    shutil.copy(ts_path, latest_path)
    print(f"[dbm_json_to_csv] latest: {latest_path}")


if __name__ == "__main__":
    main()

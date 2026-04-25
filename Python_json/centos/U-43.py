#!/usr/bin/python3
import json


def print_as_md(results: dict):
    """진단 결과를 Markdown 테이블 형식으로 출력."""
    code   = results.get("코드",     results.get("code", "U-??"))
    item   = results.get("진단 항목", results.get("diagnosisItem", "진단항목"))
    cat    = results.get("분류",     results.get("category", ""))
    risk   = results.get("위험도",   results.get("riskLevel", ""))
    result = results.get("진단 결과", results.get("diagnosisResult", ""))
    status = results.get("현황",     results.get("status", []))
    sol    = results.get("대응방안", results.get("solution", ""))

    if isinstance(status, list):
        status = " / ".join(status) if status else ""

    print(f"# {code}: {item}")
    print("")
    print("| 항목 | 내용 |")
    print("|------|------|")
    print(f"| 분류 | {cat} |")
    print(f"| 코드 | {code} |")
    print(f"| 위험도 | {risk} |")
    print(f"| 진단항목 | {item} |")
    print(f"| 진단결과 | {result} |")
    print(f"| 현황 | {status} |")
    print(f"| 대응방안 | {sol} |")

import subprocess

def check_log_review_and_reporting():
    results = {
        "분류": "로그 관리",
        "코드": "U-43",
        "위험도": "상",
        "진단 항목": "로그의 정기적 검토 및 보고",
        "진단 결과": "양호",
        "현황": [],
        "대응방안": "보안 로그, 응용 프로그램 및 시스템 로그 기록의 정기적 검토, 분석, 리포트 작성 및 보고 조치 실행"
    }

    log_files = {
        "UTMP": "/var/log/utmp",
        "WTMP": "/var/log/wtmp",
        "BTMP": "/var/log/btmp",
        "SULOG": "/var/log/sulog",
        "XFERLOG": "/var/log/xferlog"
    }

    for log_name, log_path in log_files.items():
        if check_file_existence(log_path):
            results["현황"].append({"파일명": log_name, "결과": "존재함"})
        else:
            results["현황"].append({"파일명": log_name, "결과": "존재하지 않음"})

    return results

def check_file_existence(file_path):
    try:
        with open(file_path, 'r'):
            return True
    except FileNotFoundError:
        return False

def main():
    results = check_log_review_and_reporting()
    print_as_md(results)

if __name__ == "__main__":
    main()

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

import pwd

def check_anonymous_ftp():
    results = {
        "분류": "시스템 설정",
        "코드": "U-20",
        "위험도": "상",
        "진단 항목": "Anonymous FTP 비활성화",
        "진단 결과": "",
        "현황": [],
        "대응방안": "Anonymous FTP 비활성화"
    }

    try:
        pwd.getpwnam('ftp')
        results["진단 결과"] = "취약"
        results["현황"].append("FTP 계정이 /etc/passwd 파일에 있습니다.")
    except KeyError:
        results["진단 결과"] = "양호"
        results["현황"].append("FTP 계정이 /etc/passwd 파일에 없습니다.")

    return results

def main():
    results = check_anonymous_ftp()
    print_as_md(results)

if __name__ == "__main__":
    main()

#!/usr/bin/python3
import subprocess
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


def check_snmp_service_usage():
    results = {
        "분류": "서비스 관리",
        "코드": "U-66",
        "위험도": "중",
        "진단 항목": "SNMP 서비스 구동 점검",
        "진단 결과": "",
        "현황": "",
        "대응방안": "SNMP 서비스 사용을 필요로 하지 않는 경우, 서비스를 비활성화"
    }

    # Adjusted to use universal_newlines=True for compatibility with Python 3.6
    process = subprocess.run(['ps', '-ef'], stdout=subprocess.PIPE, universal_newlines=True)
    if 'snmp' in process.stdout.lower():
        results["진단 결과"] = "취약"
        results["현황"] = "SNMP 서비스를 사용하고 있습니다."
    else:
        results["진단 결과"] = "양호"
        results["현황"] = "SNMP 서비스를 사용하지 않고 있습니다."

    return results

def main():
    snmp_service_check_results = check_snmp_service_usage()
    print_as_md(snmp_service_check_results)

if __name__ == "__main__":
    main()

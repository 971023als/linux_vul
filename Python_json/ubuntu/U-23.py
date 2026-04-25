#!/usr/bin/python3
import os
import re
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


def check_dos_vulnerable_services_disabled():
    results = {
        "분류": "서비스 관리",
        "코드": "U-23",
        "위험도": "상",
        "진단 항목": "DoS 공격에 취약한 서비스 비활성화",
        "진단 결과": None,  # 초기 상태 설정, 검사 후 결과에 따라 업데이트
        "현황": [],
        "대응방안": "사용하지 않는 DoS 공격에 취약한 서비스 비활성화"
    }

    vulnerable_services = ["echo", "discard", "daytime", "chargen"]
    xinetd_dir = "/etc/xinetd.d"
    inetd_conf = "/etc/inetd.conf"

    # /etc/xinetd.d 아래 서비스 검사
    if os.path.isdir(xinetd_dir):
        for service in vulnerable_services:
            service_path = os.path.join(xinetd_dir, service)
            if os.path.isfile(service_path):
                with open(service_path, 'r') as file:
                    content = file.read()
                    if re.search(r'^\s*disable\s*=\s*yes', content, re.MULTILINE | re.IGNORECASE) is None:
                        results["진단 결과"] = "취약"
                        results["현황"].append(f"{service} 서비스가 /etc/xinetd.d 디렉터리 내 서비스 파일에서 실행 중입니다.")

    # /etc/inetd.conf 파일 내 서비스 검사
    if os.path.isfile(inetd_conf):
        with open(inetd_conf, 'r') as file:
            content = file.read()
            for service in vulnerable_services:
                if re.search(f'^\s*{service}\s', content, re.MULTILINE | re.IGNORECASE):
                    results["진단 결과"] = "취약"
                    results["현황"].append(f"{service} 서비스가 /etc/inetd.conf 파일에서 실행 중입니다.")

    if "진단 결과" not in results or results["진단 결과"] == None:
        results["진단 결과"] = "양호"
        results["현황"].append("모든 DoS 공격에 취약한 서비스가 비활성화되어 있습니다.")

    return results

def main():
    results = check_dos_vulnerable_services_disabled()
    print_as_md(results)

if __name__ == "__main__":
    main()

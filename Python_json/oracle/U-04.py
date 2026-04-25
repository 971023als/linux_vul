#!/usr/bin/python3
import os
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


def check_shadow_password_usage():
    results = {
        "분류": "계정 관리",
        "코드": "U-04",
        "위험도": "상",
        "진단 항목": "패스워드 파일 보호",
        "진단 결과": "",
        "현황": [],
        "대응방안": "쉐도우 패스워드 사용 또는 패스워드 암호화 저장"
    }

    # /etc/passwd 파일에서 쉐도우 패스워드 사용 여부 확인
    passwd_file = "/etc/passwd"
    shadow_file = "/etc/shadow"
    shadow_used = True  # 가정: 쉐도우 패스워드 사용

    # /etc/passwd 파일 검사
    if os.path.exists(passwd_file):
        with open(passwd_file, "r", encoding='utf-8') as file:
            for line in file:
                parts = line.strip().split(":")
                if len(parts) > 1 and parts[1] != "x":
                    shadow_used = False
                    break

    # /etc/shadow 파일 존재 및 권한 검사
    if shadow_used and os.path.exists(shadow_file):
        mode = os.stat(shadow_file).st_mode
        if not (mode & 0o400):  # /etc/shadow가 읽기 전용으로 설정되어 있는지 확인
            results["현황"].append("/etc/shadow 파일이 안전한 권한 설정을 갖고 있지 않습니다.")
            shadow_used = False

    if not shadow_used:
        results["현황"].append("쉐도우 패스워드를 사용하고 있지 않거나 /etc/shadow 파일의 권한 설정이 적절하지 않습니다.")
        results["진단 결과"] = "취약"
    else:
        results["현황"].append("쉐도우 패스워드를 사용하고 있으며 /etc/shadow 파일의 권한 설정이 적절합니다.")
        results["진단 결과"] = "양호"

    return results

def main():
    results = check_shadow_password_usage()
    print_as_md(results)

if __name__ == "__main__":
    main()

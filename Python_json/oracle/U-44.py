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


def check_for_non_root_uid_zero():
    results = {
        "분류": "계정관리",
        "코드": "U-44",
        "위험도": "중",
        "진단 항목": "root 이외의 UID가 '0' 금지",
        "진단 결과": "양호",  # Assume "Good" until proven otherwise
        "현황": [],
        "대응방안": "root 계정 외 UID 0 사용 금지"
    }

    with open('/etc/passwd', 'r') as passwd_file:
        for line in passwd_file:
            user_info = line.split(':')
            if user_info[2] == '0' and user_info[0] != 'root':
                results["진단 결과"] = "취약"
                results["현황"].append(f"root 계정과 동일한 UID(0)를 갖는 계정이 존재합니다: {user_info[0]}")
                break

    if results["진단 결과"] == "양호":
        results["현황"].append("root 계정 외에 UID 0을 갖는 계정이 존재하지 않습니다.")

    return results

def main():
    uid_zero_check_results = check_for_non_root_uid_zero()
    print_as_md(uid_zero_check_results)

if __name__ == "__main__":
    main()

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


def check_password_min_length():
    results = {
        "분류": "계정관리",
        "코드": "U-46",
        "위험도": "중",
        "진단 항목": "패스워드 최소 길이 설정",
        "진단 결과": "",  # 최초 상태 설정
        "현황": [],
        "대응방안": "패스워드 최소 길이 8자 이상으로 설정"
    }

    files_to_check = [
        ("/etc/login.defs", "PASS_MIN_LEN"),
        ("/etc/pam.d/system-auth", "minlen"),
        ("/etc/pam.d/password-auth", "minlen"),
        ("/etc/security/pwquality.conf", "minlen")
    ]

    file_exists_count = 0
    minlen_file_exists_count = 0
    appropriate_settings_count = 0

    for file_path, setting_key in files_to_check:
        if os.path.isfile(file_path):
            file_exists_count += 1
            with open(file_path, 'r') as file:
                settings = file.read()
                if setting_key.lower() in settings.lower():
                    minlen_file_exists_count += 1
                    min_length = None
                    for line in settings.splitlines():
                        if setting_key.lower() in line.lower() and not line.strip().startswith("#"):
                            min_length = [int(s) for s in line.split() if s.isdigit()]
                            if min_length and min_length[0] < 8:
                                results["진단 결과"] = "취약"
                                results["현황"].append(f"{file_path} 파일에 {setting_key}가 8 미만으로 설정되어 있습니다.")
                            elif min_length:
                                appropriate_settings_count += 1

    # 모든 조건을 평가한 후의 상태 업데이트
    if file_exists_count == 0:
        results["진단 결과"] = "취약"
        results["현황"].append("패스워드 최소 길이를 설정하는 파일이 없습니다.")
    elif minlen_file_exists_count == appropriate_settings_count:
        results["진단 결과"] = "양호"
        results["현황"].append("모든 검사된 파일에서 패스워드 최소 길이 설정이 적절히 구성되어 있습니다.")
    else:
        results["진단 결과"] = "취약"
        if not results["현황"]:  # 현황이 비어있다면 추가 메시지 제공
            results["현황"].append("일부 파일에서 패스워드 최소 길이 설정이 부적절하게 구성되어 있습니다.")

    return results

def main():
    password_min_length_check_results = check_password_min_length()
    print_as_md(password_min_length_check_results)

if __name__ == "__main__":
    main()

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

import glob

def check_session_timeout():
    results = {
        "분류": "계정관리",
        "코드": "U-54",
        "위험도": "하",
        "진단 항목": "Session Timeout 설정",
        "진단 결과": "양호",  # Assume "Good" until proven otherwise
        "현황": [],
        "대응방안": "Session Timeout을 600초(10분) 이하로 설정"
    }

    # Files to check for session timeout settings
    check_files = ["/etc/profile", "/etc/csh.login", "/etc/csh.cshrc"]
    check_files += glob.glob("/home/*/.profile")

    file_exists_count = 0
    no_tmout_setting_file = 0

    for file_path in check_files:
        if os.path.isfile(file_path):
            file_exists_count += 1
            with open(file_path, 'r') as file:
                contents = file.read()
                if "TMOUT" in contents or "autologout" in contents:
                    # Extract TMOUT or autologout values and check them
                    for line in contents.splitlines():
                        if line.strip().startswith("TMOUT") or "autologout" in line:
                            setting_value = line.split("=")[-1].strip()
                            try:
                                if int(setting_value) > 600 and "TMOUT" in line:
                                    results["진단 결과"] = "취약"
                                    results["현황"].append(f"{file_path} 파일에 세션 타임아웃이 600초 이하로 설정되지 않았습니다.")
                                    break
                                elif int(setting_value) > 10 and "autologout" in line:
                                    results["진단 결과"] = "취약"
                                    results["현황"].append(f"{file_path} 파일에 세션 타임아웃이 10분 이하로 설정되지 않았습니다.")
                                    break
                            except ValueError:
                                continue  # Skip lines where the value is not an integer
                else:
                    no_tmout_setting_file += 1

    if file_exists_count == 0:
        results["진단 결과"] = "취약"
        results["현황"].append("세션 타임아웃을 설정하는 파일이 없습니다.")
    elif file_exists_count == no_tmout_setting_file:
        results["진단 결과"] = "취약"
        results["현황"].append("세션 타임아웃을 설정한 파일이 없습니다.")

    return results

def main():
    session_timeout_check_results = check_session_timeout()
    print_as_md(session_timeout_check_results)

if __name__ == "__main__":
    main()

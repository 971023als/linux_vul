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

import re
import pwd

def check_insecure_path():
    results = {
        "분류": "파일 및 디렉터리 관리",
        "코드": "U-05",
        "위험도": "상",
        "진단 항목": "root홈, 패스 디렉터리 권한 및 패스 설정",
        "진단 결과": "",
        "현황": [],
        "대응방안": "PATH 환경변수에 '.' 이 맨 앞이나 중간에 포함되지 않도록 설정"
    }

    global_files = [
        "/etc/profile",
        "/etc/.login",
        "/etc/csh.cshrc",
        "/etc/csh.login",
        "/etc/environment"
    ]

    user_files = [
        ".profile",
        ".cshrc",
        ".login",
        ".kshrc",
        ".bash_profile",
        ".bashrc",
        ".bash_login"
    ]

    # 글로벌 설정 파일 검사
    for file in global_files:
        if os.path.exists(file):
            with open(file, 'r') as f:
                content = f.read()
                if re.search(r'\b\.\b|(^|:)\.(:|$)', content):
                    results["현황"].append(f"{file} 파일 내에 PATH 환경 변수에 '.' 또는 중간에 '::' 이 포함되어 있습니다.\n")

    # 사용자 홈 디렉터리 설정 파일 검사
    users = pwd.getpwall()
    for user in users:
        home_dir = user.pw_dir
        for file in user_files:
            file_path = os.path.join(home_dir, file)
            if os.path.exists(file_path):
                with open(file_path, 'r') as f:
                    content = f.read()
                    if re.search(r'\b\.\b|(^|:)\.(:|$)', content):
                        results["현황"].append(f"{file_path} 파일 내에 PATH 환경 변수에 '.' 또는 '::' 이 포함되어 있습니다.\n")

    # 진단 결과 설정
    if results["현황"]:
        results["진단 결과"] = "취약"
    else:
        results["진단 결과"] = "양호"

    return results

def main():
    results = check_insecure_path()
    print_as_md(results)

if __name__ == "__main__":
    main()

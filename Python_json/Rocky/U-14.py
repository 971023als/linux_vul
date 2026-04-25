#!/usr/bin/python3
import os
import pwd
import stat
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


def check_user_system_start_files():
    results = {
        "분류": "파일 및 디렉터리 관리",
        "코드": "U-14",
        "위험도": "상",
        "진단 항목": "사용자, 시스템 시작파일 및 환경파일 소유자 및 권한 설정",
        "진단 결과": "",  # 초기 진단 결과 설정하지 않음
        "현황": [],
        "대응방안": "홈 디렉터리 환경변수 파일 소유자가 root 또는 해당 계정으로 지정되어 있고, 쓰기 권한이 부여된 경우"
    }

    start_files = [".profile", ".cshrc", ".login", ".kshrc", ".bash_profile", ".bashrc", ".bash_login"]
    vulnerable_files = []

    # 모든 사용자 홈 디렉터리 가져오기
    user_homes = [user.pw_dir for user in pwd.getpwall() if os.path.isdir(user.pw_dir)]

    for home in user_homes:
        for start_file in start_files:
            file_path = os.path.join(home, start_file)
            if os.path.isfile(file_path):
                file_stat = os.stat(file_path)
                mode = file_stat.st_mode

                # 파일 소유자가 root 또는 해당 사용자가 아니거나, 다른 사용자에게 쓰기 권한이 있을 경우
                if not (file_stat.st_uid == 0 or file_stat.st_uid == pwd.getpwnam(os.path.basename(home)).pw_uid) or (mode & stat.S_IWOTH):
                    vulnerable_files.append(file_path)

    if vulnerable_files:
        results["진단 결과"] = "취약"
        results["현황"] = vulnerable_files
    else:
        results["진단 결과"] = "양호"
        results["현황"].append("모든 홈 디렉터리 내 시작파일 및 환경파일이 적절한 소유자와 권한 설정을 가지고 있습니다.")

    return results

def main():
    user_system_start_files_check_results = check_user_system_start_files()
    print_as_md(user_system_start_files_check_results)

if __name__ == "__main__":
    main()

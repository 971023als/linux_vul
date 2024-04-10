#!/usr/bin/python3
import os
import json
import pwd

def check_unnecessary_accounts():
    results = {
        "분류": "계정관리",
        "코드": "U-49",
        "위험도": "하",
        "진단 항목": "불필요한 계정 제거",
        "진단 결과": "양호",  # Assume "Good" until proven otherwise
        "현황": [],
        "대응방안": "불필요한 계정이 존재하지 않도록 관리"
    }

    # 로그인이 가능한 계정만 대상으로 함
    login_shells = ["/bin/bash", "/bin/sh"]
    # 불필요한 계정 예시 목록 (사용 환경에 따라 수정 필요)
    unnecessary_accounts = [
        "user", "test", "guest", "info", "adm", "mysql", "user1"
    ]

    # 시스템 계정을 제외한 로그인 가능한 계정 찾기
    all_accounts = pwd.getpwall()
    found_accounts = []
    for account in all_accounts:
        if account.pw_shell in login_shells and account.pw_name in unnecessary_accounts:
            found_accounts.append(account.pw_name)

    if found_accounts:
        results["진단 결과"] = "취약"
        results["현황"].append("불필요한 계정이 존재합니다: " + ", ".join(found_accounts))
    else:
        # 양호: 불필요한 로그인 가능한 계정이 없음
        results["진단 결과"] = "양호"
        results["현황"].append("불필요한 계정이 존재하지 않습니다.")

    return results

def main():
    unnecessary_accounts_check_results = check_unnecessary_accounts()
    print(json.dumps(unnecessary_accounts_check_results, ensure_ascii=False, indent=4))

if __name__ == "__main__":
    main()
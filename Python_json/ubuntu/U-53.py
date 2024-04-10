#!/usr/bin/python3
import json
import os

def check_user_shell():
    unnecessary_accounts = [
        "daemon", "bin", "sys", "adm", "listen", "nobody", "nobody4",
        "noaccess", "diag", "operator", "gopher", "games", "ftp", "apache",
        "httpd", "www-data", "mysql", "mariadb", "postgres", "mail", "postfix",
        "news", "lp", "uucp", "nuucp"
    ]

    results = {
        "분류": "계정관리",
        "코드": "U-53",
        "위험도": "하",
        "진단 항목": "사용자 shell 점검",
        "진단 결과": "양호",  # 초기 상태를 "양호"로 설정합니다.
        "현황": [],
        "대응방안": "로그인이 필요하지 않은 계정에 /bin/false 또는 /sbin/nologin 쉘 부여"
    }

    checked_accounts = 0  # 검사된 계정의 수를 추적합니다.

    if os.path.isfile("/etc/passwd"):
        with open("/etc/passwd", 'r') as file:
            for line in file:
                fields = line.strip().split(":")
                if len(fields) < 7:
                    continue
                username, shell = fields[0], fields[-1]
                if username in unnecessary_accounts:
                    checked_accounts += 1
                    if shell not in ["/bin/false", "/sbin/nologin"]:
                        results["진단 결과"] = "취약"  # 취약한 계정 발견 시 "취약"으로 상태 변경
                        results["현황"].append(f"계정 {username}에 적절한 쉘이 부여되지 않았습니다: {shell}")

    if checked_accounts == 0:
        results["현황"].append("검사 대상이 되는 불필요한 계정이 없습니다.")
    elif "취약" not in results["진단 결과"]:  # 취약한 계정이 없을 때
        results["현황"].append("모든 필요 없는 계정에 /bin/false 또는 /sbin/nologin 쉘이 부여되어 있습니다.")

    return results

def main():
    user_shell_check_results = check_user_shell()
    print(json.dumps(user_shell_check_results, ensure_ascii=False, indent=4))

if __name__ == "__main__":
    main()

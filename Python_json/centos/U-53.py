#!/usr/bin/python3
import os
import json

def check_user_shell():
    results = {
        "분류": "계정관리",
        "코드": "U-53",
        "위험도": "하",
        "진단 항목": "사용자 shell 점검",
        "진단 결과": "양호",  # Assume "Good" until proven otherwise
        "현황": [],
        "대응방안": "로그인이 필요하지 않은 계정에 /bin/false 또는 /sbin/nologin 쉘 부여"
    }

    unnecessary_accounts = [
        "daemon", "bin", "sys", "adm", "listen", "nobody", "nobody4",
        "noaccess", "diag", "operator", "gopher", "games", "ftp", "apache",
        "httpd", "www-data", "mysql", "mariadb", "postgres", "mail", "postfix",
        "news", "lp", "uucp", "nuucp"
    ]
    
    if os.path.isfile("/etc/passwd"):
        with open("/etc/passwd", 'r') as file:
            passwd_contents = file.readlines()
            for line in passwd_contents:
                fields = line.strip().split(":")
                username, shell = fields[0], fields[-1]
                if username in unnecessary_accounts:
                    if shell not in ["/bin/false", "/sbin/nologin"]:
                        results["진단 결과"] = "취약"
                        results["현황"].append(f"계정 {username}에 /bin/false 또는 /sbin/nologin 쉘이 부여되지 않았습니다.")
                        break
    else:
        results["진단 결과"] = "취약"
        results["현황"].append("/etc/passwd 파일이 없습니다.")

    return results

def main():
    user_shell_check_results = check_user_shell()
    print(json.dumps(user_shell_check_results, ensure_ascii=False, indent=4))

if __name__ == "__main__":
    main()

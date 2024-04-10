#!/usr/bin/python3
import os
import json

def check_admin_group_accounts():
    results = {
        "분류": "계정관리",
        "코드": "U-50",
        "위험도": "하",
        "진단 항목": "관리자 그룹에 최소한의 계정 포함",
        "진단 결과": "양호",  # 기본적으로 "양호"로 가정
        "현황": [],
        "대응방안": "관리자 그룹(root)에 불필요한 계정이 등록되지 않도록 관리"
    }

    unnecessary_accounts = [
        "bin", "sys", "adm", "listen", "nobody4", "noaccess", "diag",
        "operator", "gopher", "games", "ftp", "apache", "httpd", "www-data",
        "mysql", "mariadb", "postgres", "mail", "postfix", "news", "lp",
        "uucp", "nuucp", "sync", "shutdown", "halt", "mailnull", "smmsp",
        "manager", "dumper", "abuse", "webmaster", "noc", "security",
        "hostmaster", "info", "marketing", "sales", "support", "accounts",
        "help", "admin", "guest", "user", "ubuntu"
    ]

    root_group_found = False

    if os.path.isfile("/etc/group"):
        with open("/etc/group", 'r') as file:
            for group_line in file:
                group_info = group_line.strip().split(":")
                if len(group_info) >= 4 and group_info[0] == "root":
                    root_group_found = True
                    root_members = group_info[3].split(',')
                    found_accounts = [acc for acc in root_members if acc in unnecessary_accounts]
                    if found_accounts:
                        results["진단 결과"] = "취약"
                        results["현황"].append("관리자 그룹(root)에 불필요한 계정이 등록되어 있습니다: " + ", ".join(found_accounts))
                    else:
                        results["현황"].append("관리자 그룹(root)에 불필요한 계정이 없습니다.")
                    break
    else:
        results["진단 결과"] = "취약"
        results["현황"].append("/etc/group 파일이 없습니다.")

    if not root_group_found:
        results["진단 결과"] = "오류"
        results["현황"].append("관리자 그룹(root)을 /etc/group 파일에서 찾을 수 없습니다.")

    return results

def main():
    admin_group_accounts_check_results = check_admin_group_accounts()
    print(json.dumps(admin_group_accounts_check_results, ensure_ascii=False, indent=4))

if __name__ == "__main__":
    main()

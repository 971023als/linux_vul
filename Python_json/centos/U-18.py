#!/usr/bin/python3
import json
import sys

# Python 3.7 이상에서 표준 출력의 인코딩을 UTF-8로 설정
if sys.stdout.encoding != 'UTF-8':
    sys.stdout.reconfigure(encoding='utf-8')

def check_access_control_files():
    results = {
        "분류": "파일 및 디렉터리 관리",
        "코드": "U-18",
        "위험도": "상",
        "진단 항목": "접속 IP 및 포트 제한",
        "진단 결과": "",
        "현황": [],
        "대응방안": "특정 호스트에 대한 IP 주소 및 포트 제한 설정"
    }

    hosts_deny_path = '/etc/hosts.deny'
    hosts_allow_path = '/etc/hosts.allow'

    hosts_deny_exists = check_file_exists_and_content(hosts_deny_path, 'ALL: ALL')
    hosts_allow_exists = check_file_exists_and_content(hosts_allow_path, 'ALL: ALL')

    if not hosts_deny_exists:
        results["진단 결과"] = "취약"
        results["현황"].append(f"{hosts_deny_path} 파일에 'ALL: ALL' 설정이 없거나 파일이 없습니다.")
    elif hosts_allow_exists:
        results["진단 결과"] = "취약"
        results["현황"].append(f"{hosts_allow_path} 파일에 'ALL: ALL' 설정이 있습니다.")
    else:
        results["진단 결과"] = "양호"
        results["현황"].append("적절한 IP 및 포트 제한 설정이 확인되었습니다.")

    return results

def check_file_exists_and_content(file_path, search_string):
    try:
        with open(file_path, 'r', encoding='utf-8') as file:
            for line in file:
                if search_string.lower() in line.lower() and not line.strip().startswith('#'):
                    return True
    except FileNotFoundError:
        pass
    return False

def main():
    results = check_access_control_files()
    print(json.dumps(results, ensure_ascii=False, indent=4))

if __name__ == "__main__":
    main()

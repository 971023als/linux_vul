#!/usr/bin/python3
import json
import sys

# Python 3.7 이상에서 표준 출력의 인코딩을 UTF-8로 설정
if sys.stdout.encoding != 'UTF-8':
    sys.stdout.reconfigure(encoding='utf-8')
def check_file_exists_and_content(file_path, content):
    try:
        with open(file_path, 'r') as file:
            if content in file.read():
                return 'exists_and_content'
        return 'exists_no_content'
    except FileNotFoundError:
        return 'not_exists'

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

    hosts_deny_status = check_file_exists_and_content(hosts_deny_path, 'ALL: ALL')
    hosts_allow_status = check_file_exists_and_content(hosts_allow_path, 'ALL: ALL')

    if hosts_deny_status == 'not_exists':
        results["진단 결과"] = "취약"
        results["현황"].append(f"{hosts_deny_path} 파일이 없습니다.")
    elif hosts_deny_status == 'exists_no_content':
        results["진단 결과"] = "취약"
        results["현황"].append(f"{hosts_deny_path} 파일에 'ALL: ALL' 설정이 없습니다.")

    if hosts_allow_status == 'exists_and_content':
        results["진단 결과"] = "취약"
        results["현황"].append(f"{hosts_allow_path} 파일에 'ALL: ALL' 설정이 있습니다.")

    if not results["현황"]:
        results["진단 결과"] = "양호"
        results["현황"].append("적절한 IP 및 포트 제한 설정이 확인되었습니다.")

    return results

def main():
    results = check_access_control_files()
    print(json.dumps(results, ensure_ascii=False, indent=4))

if __name__ == "__main__":
    main()


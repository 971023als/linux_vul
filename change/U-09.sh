#!/usr/bin/python3
import os
import stat
import json
import sys

# Ensure standard output encoding is set to UTF-8
if sys.version_info.major >= 3:
    try:
        sys.stdout.reconfigure(encoding='utf-8')
    except AttributeError:
        # This is for compatibility with Python versions before 3.7
        # In Python 3.7 and above, sys.stdout.reconfigure is available
        pass
        
def check_etc_hosts_permissions():
    results = {
        "분류": "파일 및 디렉터리 관리",
        "코드": "U-09",
        "위험도": "상",
        "진단 항목": "/etc/hosts 파일 소유자 및 권한 설정",
        "진단 결과": "",
        "현황": [],
        "대응방안": "/etc/hosts 파일의 소유자가 root이고, 권한이 600 이하인 경우"
    }

    hosts_file = '/etc/hosts'
    if os.path.exists(hosts_file):
        file_stat = os.stat(hosts_file)
        mode = oct(file_stat.st_mode)[-3:]
        owner_uid = file_stat.st_uid

        # Check if owner is root
        if owner_uid == 0:
            # Check file permissions
            if int(mode, 8) <= 0o600:
                results["진단 결과"] = "양호"
                results["현황"].append(f"/etc/hosts 파일의 소유자가 root이고, 권한이 {mode}입니다.")
            else:
                results["진단 결과"] = "취약"
                results["현황"].append(f"/etc/hosts 파일의 권한이 {mode}로 설정되어 있어 취약합니다.")
        else:
            results["진단 결과"] = "취약"
            results["현황"].append("/etc/hosts 파일의 소유자가 root가 아닙니다.")
    else:
        results["진단 결과"] = "N/A"
        results["현황"].append("/etc/hosts 파일이 없습니다.")

    return results

def main():
    results = check_etc_hosts_permissions()
    print(json.dumps(results, ensure_ascii=False, indent=4))

if __name__ == "__main__":
    main()

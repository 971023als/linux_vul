#!/usr/bin/python3
import os
import stat
import json
import sys

def check_etc_passwd_permissions():
    results = {
        "분류": "파일 및 디렉터리 관리",
        "코드": "U-07",
        "위험도": "상",
        "진단 항목": "/etc/passwd 파일 소유자 및 권한 설정",
        "진단 결과": "",
        "현황": [],
        "대응방안": "/etc/passwd 파일의 소유자가 root이고, 권한이 644 이하인 경우"
    }

    passwd_file = '/etc/passwd'
    if os.path.exists(passwd_file):
        file_stat = os.stat(passwd_file)
        mode = oct(file_stat.st_mode)[-3:]
        owner_uid = file_stat.st_uid

        # Check if owner is root
        if owner_uid == 0:
            # Check file permissions
            if int(mode, 8) <= 0o644:
                results["진단 결과"] = "양호"
                results["현황"].append(f"/etc/passwd 파일의 소유자가 root이고, 권한이 {mode}입니다.")
            else:
                results["진단 결과"] = "취약"
                results["현황"].append(f"/etc/passwd 파일의 권한이 {mode}로 설정되어 있어 취약합니다.")
        else:
            results["진단 결과"] = "취약"
            results["현황"].append("/etc/passwd 파일의 소유자가 root가 아닙니다.")
    else:
        results["진단 결과"] = "N/A"
        results["현황"].append("/etc/passwd 파일이 없습니다.")

    return results
    
def main():
    results = check_etc_passwd_permissions()
    # 결과를 콘솔에 출력할 때
    print(json.dumps(results, ensure_ascii=False, indent=4))
    # 결과를 파일에 쓸 때
    with open('results.json', 'w', encoding='utf-8') as f:
        json.dump(results, f, ensure_ascii=False, indent=4)

if __name__ == "__main__":
    main()

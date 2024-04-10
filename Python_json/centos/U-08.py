#!/usr/bin/python3
import os
import stat
import json
import sys

# Python3에서 표준 출력의 인코딩을 UTF-8로 설정
if sys.version_info.major == 3:
    try:
        sys.stdout.reconfigure(encoding='utf-8')
    except AttributeError:
        # Python 3.6 이하 버전에는 reconfigure 메소드가 없으므로, 이 경우에는 별도의 처리가 필요 없음
        pass

def check_etc_shadow_permissions():
    results = {
        "분류": "파일 및 디렉터리 관리",
        "코드": "U-08",
        "위험도": "상",
        "진단 항목": "/etc/shadow 파일 소유자 및 권한 설정",
        "진단 결과": "",
        "현황": [],
        "대응방안": "/etc/shadow 파일의 소유자가 root이고, 권한이 400 이하인 경우"
    }

    shadow_file = '/etc/shadow'
    if os.path.exists(shadow_file):
        file_stat = os.stat(shadow_file)
        mode = oct(file_stat.st_mode)[-3:]
        owner_uid = file_stat.st_uid

        # Check if owner is root
        if owner_uid == 0:
            # Check file permissions
            if int(mode, 8) <= 0o400:
                results["진단 결과"] = "양호"
                results["현황"].append(f"/etc/shadow 파일의 소유자가 root이고, 권한이 {mode}입니다.")
            else:
                results["진단 결과"] = "취약"
                results["현황"].append(f"/etc/shadow 파일의 권한이 {mode}로 설정되어 있어 취약합니다.")
        else:
            results["진단 결과"] = "취약"
            results["현황"].append("/etc/shadow 파일의 소유자가 root가 아닙니다.")
    else:
        results["진단 결과"] = "N/A"
        results["현황"].append("/etc/shadow 파일이 없습니다.")

    return results

def main():
    results = check_etc_shadow_permissions()
    print(json.dumps(results, ensure_ascii=False, indent=4))

if __name__ == "__main__":
    main()
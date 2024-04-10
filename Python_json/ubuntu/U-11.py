#!/usr/bin/python3
import os
import stat
import json
import pwd

def check_syslog_file_permissions():
    results = {
        "분류": "파일 및 디렉터리 관리",
        "코드": "U-11",
        "위험도": "상",
        "진단 항목": "/etc/syslog.conf 파일 소유자 및 권한 설정",
        "진단 결과": "파일 없음",  # 기본 상태
        "현황": [],
        "대응방안": "/etc/syslog.conf 파일의 소유자가 root(또는 bin, sys)이고, 권한이 640 이하인 경우"
    }

    syslog_conf_files = ["/etc/rsyslog.conf", "/etc/syslog.conf", "/etc/syslog-ng.conf"]
    found_files = []

    for file_path in syslog_conf_files:
        if os.path.isfile(file_path):
            found_files.append(file_path)
            file_stat = os.stat(file_path)
            mode = oct(file_stat.st_mode & 0o777)[-3:]
            owner_uid = file_stat.st_uid
            owner_name = pwd.getpwuid(owner_uid).pw_name

            if owner_name in ['root', 'bin', 'sys'] and int(mode, 8) <= 0o640:
                results["현황"].append(f"{file_path} 파일의 소유자가 {owner_name}이며, 권한이 {mode}입니다. 조건 충족.")
            else:
                permission_issue = f"{file_path} 파일의 소유자가 {owner_name}이며, 권한이 {mode}입니다."
                if owner_name not in ['root', 'bin', 'sys']:
                    permission_issue += " 소유자가 root, bin, sys가 아닙니다."
                if int(mode, 8) > 0o640:
                    permission_issue += " 권한이 640을 초과합니다."
                results["현황"].append(permission_issue)

    if found_files:
        if "조건 충족." in ''.join(results["현황"]):
            results["진단 결과"] = "양호"
        else:
            results["진단 결과"] = "취약"
    else:
        results["현황"].append("검사 대상이 되는 syslog 관련 파일이 시스템에 존재하지 않습니다.")

    return results

def main():
    results = check_syslog_file_permissions()
    print(json.dumps(results, ensure_ascii=False, indent=4))

if __name__ == "__main__":
    main()

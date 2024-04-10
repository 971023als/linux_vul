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
        "진단 결과": "N/A",  # 파일 존재 여부에 따라 업데이트될 예정
        "현황": [],
        "대응방안": "/etc/syslog.conf 파일의 소유자가 root(또는 bin, sys)이고, 권한이 640 이하인 경우"
    }

    syslog_conf_files = ["/etc/rsyslog.conf", "/etc/syslog.conf", "/etc/syslog-ng.conf"]
    file_exists_count = 0
    compliant_files_count = 0

    for file_path in syslog_conf_files:
        if os.path.isfile(file_path):
            file_exists_count += 1
            file_stat = os.stat(file_path)
            mode = oct(file_stat.st_mode)[-3:]
            owner_uid = file_stat.st_uid
            owner_name = pwd.getpwuid(owner_uid).pw_name

            # 조건을 충족하는 경우
            if owner_name in ['root', 'bin', 'sys'] and int(mode, 8) <= 0o640:
                compliant_files_count += 1
                results["현황"].append(f"{file_path} 파일의 소유자가 {owner_name}이고, 권한이 {mode}입니다.")
            else:
                results["현황"].append(f"{file_path} 파일의 소유자나 권한이 기준에 부합하지 않습니다.")

    if file_exists_count > 0:
        if compliant_files_count == file_exists_count:
            results["진단 결과"] = "양호"
        else:
            results["진단 결과"] = "취약"
    else:
        results["진단 결과"] = "파일 없음"

    return results

def main():
    results = check_syslog_file_permissions()
    print(json.dumps(results, ensure_ascii=False, indent=4))

if __name__ == "__main__":
    main()

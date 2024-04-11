#!/usr/bin/python3
import os
import stat
import json

def check_cron_permissions():
    results = {
        "분류": "서비스 관리",
        "코드": "U-22",
        "위험도": "상",
        "진단 항목": "crond 파일 소유자 및 권한 설정",
        "진단 결과": None,  # 초기 상태 설정, 검사 후 결과에 따라 업데이트
        "현황": [],
        "대응방안": "crontab 명령어 일반사용자 금지 및 cron 관련 파일 640 이하 권한 설정"
    }

    crontab_paths = ["/usr/bin/crontab", "/usr/sbin/crontab", "/bin/crontab"]
    crontab_path = next((path for path in crontab_paths if os.path.exists(path)), None)
    if crontab_path:
        crontab_permission = oct(os.stat(crontab_path).st_mode)[-3:]
        if int(crontab_permission, 8) > 750:
            results["진단 결과"] = "취약"
            results["현황"].append(f"{crontab_path} 명령어의 권한이 750보다 큽니다.")
    
    cron_directories = ["/etc/cron.hourly", "/etc/cron.daily", "/etc/cron.weekly", "/etc/cron.monthly", "/var/spool/cron", "/var/spool/cron/crontabs"]
    cron_files = ["/etc/crontab", "/etc/cron.allow", "/etc/cron.deny"]

    for directory in cron_directories:
        if os.path.isdir(directory):
            for root, dirs, files in os.walk(directory):
                for file in files:
                    cron_files.append(os.path.join(root, file))

    for cron_file in cron_files:
        if os.path.isfile(cron_file):
            file_stat = os.stat(cron_file)
            file_permission = oct(file_stat.st_mode)[-3:]
            owner = file_stat.st_uid

            if owner != 0 or int(file_permission, 8) > 640:
                results["진단 결과"] = "취약"
                if owner != 0:
                    results["현황"].append(f"{cron_file} 파일의 소유자(owner)가 root가 아닙니다.")
                if int(file_permission, 8) > 640:
                    results["현황"].append(f"{cron_file} 파일의 권한이 640보다 큽니다.")

    if "진단 결과" not in results or results["진단 결과"] == None:
        results["진단 결과"] = "양호"
        results["현황"].append("모든 cron 관련 파일 및 명령어가 적절한 권한 설정을 가지고 있습니다.")

    return results

def main():
    results = check_cron_permissions()
    print(json.dumps(results, ensure_ascii=False, indent=4))

if __name__ == "__main__":
    main()

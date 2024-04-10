#!/usr/bin/python3
import os
import stat
import json

def check_ftpusers_file_permissions():
    results = {
        "분류": "서비스 관리",
        "코드": "U-63",
        "위험도": "하",
        "진단 항목": "ftpusers 파일 소유자 및 권한 설정",
        "진단 결과": "",  # 초기 값 설정하지 않음
        "현황": [],
        "대응방안": "ftpusers 파일의 소유자를 root로 설정하고, 권한을 640 이하로 설정"
    }

    ftpusers_files = [
        "/etc/ftpusers", "/etc/pure-ftpd/ftpusers", "/etc/wu-ftpd/ftpusers",
        "/etc/vsftpd/ftpusers", "/etc/proftpd/ftpusers", "/etc/ftpd/ftpusers",
        "/etc/vsftpd.ftpusers", "/etc/vsftpd.user_list", "/etc/vsftpd/user_list"
    ]

    file_checked_and_secure = False

    for ftpusers_file in ftpusers_files:
        if os.path.isfile(ftpusers_file):
            file_checked_and_secure = True  # 파일 존재 확인
            st = os.stat(ftpusers_file)
            mode = st.st_mode
            owner = st.st_uid
            permissions = stat.S_IMODE(mode)

            # Check if owner is root and permissions are 640 or less
            if owner != 0 or permissions > 0o640:
                results["진단 결과"] = "취약"
                if owner != 0:
                    results["현황"].append(f"{ftpusers_file} 파일의 소유자(owner)가 root가 아닙니다.")
                if permissions > 0o640:
                    results["현황"].append(f"{ftpusers_file} 파일의 권한이 640보다 큽니다.")
    
    # 파일 검사 후 취약하지 않은 경우 양호로 설정
    if not results["현황"]:
        if file_checked_and_secure:
            results["진단 결과"] = "양호"
            results["현황"].append("모든 ftpusers 파일이 적절한 소유자 및 권한 설정을 가지고 있습니다.")
        else:
            results["진단 결과"] = "취약"
            results["현황"].append("ftp 접근제어 파일이 없습니다.")

    return results

def main():
    ftpusers_file_check_results = check_ftpusers_file_permissions()
    print(json.dumps(ftpusers_file_check_results, ensure_ascii=False, indent=4))

if __name__ == "__main__":
    main()

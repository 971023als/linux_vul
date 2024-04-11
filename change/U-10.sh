#!/usr/bin/python3
import os
import stat
import json

def check_file_ownership_and_permissions(file_path):
    try:
        file_stat = os.stat(file_path)
        mode = oct(file_stat.st_mode)[-3:]
        owner_uid = file_stat.st_uid

        # Check if owner is root and permissions are less than 600
        if owner_uid == 0 and int(mode, 8) < 0o600:
            return False
        else:
            return True
    except FileNotFoundError:
        # File does not exist
        return None

def check_directory_files_ownership_and_permissions(directory_path):
    if not os.path.exists(directory_path) or not os.path.isdir(directory_path):
        return None

    files_check_result = True
    for root, _, files in os.walk(directory_path):
        for name in files:
            file_path = os.path.join(root, name)
            if not check_file_ownership_and_permissions(file_path):
                files_check_result = False
                break
    return files_check_result

def main():
    results = {
        "분류": "파일 및 디렉터리 관리",
        "코드": "U-10",
        "위험도": "상",
        "진단 항목": "/etc/(x)inetd.conf 파일 소유자 및 권한 설정",
        "진단 결과": None,  # 초기 값은 None으로 설정하고 검사 후 업데이트
        "현황": [],
        "대응방안": "/etc/(x)inetd.conf 파일과 /etc/xinetd.d 디렉터리 내 파일의 소유자가 root이고, 권한이 600 미만인 경우"
    }

    files_to_check = ['/etc/inetd.conf', '/etc/xinetd.conf']
    directories_to_check = ['/etc/xinetd.d']
    check_passed = True

    for file_path in files_to_check:
        if not check_file_ownership_and_permissions(file_path):
            results["현황"].append(f"{file_path} 파일의 소유자가 root가 아니거나 권한이 600 미만입니다.")
            check_passed = False

    for directory_path in directories_to_check:
        if not check_directory_files_ownership_and_permissions(directory_path):
            results["현황"].append(f"{directory_path} 디렉터리 내 파일의 소유자가 root가 아니거나 권한이 600 미만입니다.")
            check_passed = False

    # 검사 결과에 따라 진단 결과 업데이트
    if check_passed:
        results["진단 결과"] = "양호"
    else:
        results["진단 결과"] = "취약"

    print(json.dumps(results, ensure_ascii=False, indent=4))

if __name__ == "__main__":
    main()

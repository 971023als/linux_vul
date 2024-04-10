#!/usr/bin/python3
import os
import json
import glob

def get_umask_values_from_file(file_path):
    """Extracts and returns umask values found in the given file."""
    umask_values = []
    with open(file_path, 'r') as file:
        for line in file:
            if 'umask' in line and not line.strip().startswith('#'):
                parts = line.split('umask')
                if len(parts) > 1:
                    value_part = parts[1].split()
                    value = value_part[0].split('=')[-1] if '=' in value_part[0] else value_part[0]
                    umask_values.append(value.strip('`'))
    return umask_values

def check_umask_settings():
    results = {
        "분류": "파일 및 디렉토리 관리",
        "코드": "U-56",
        "위험도": "중",
        "진단 항목": "UMASK 설정 관리",
        "진단 결과": "양호",
        "현황": [],
        "대응방안": "UMASK 값이 022 이상으로 설정"
    }

    files_to_check = [
        "/etc/profile", "/etc/bash.bashrc", "/etc/csh.login", "/etc/csh.cshrc",
        *glob.glob("/home/*/.profile"), *glob.glob("/home/*/.bashrc"),
        *glob.glob("/home/*/.cshrc"), *glob.glob("/home/*/.login")
    ]

    checked_files = 0
    for file_path in files_to_check:
        if os.path.isfile(file_path):
            checked_files += 1
            umask_values = get_umask_values_from_file(file_path)
            for value in umask_values:
                if int(value, 8) < int('022', 8):
                    results["진단 결과"] = "취약"
                    results["현황"].append(f"{file_path} 파일에서 UMASK 값 ({value})이 022 이상으로 설정되지 않았습니다.")
    if results["진단 결과"] == "양호" and checked_files > 0:
        results["현황"].append("모든 검사된 파일에서 UMASK 값이 022 이상으로 적절히 설정되었습니다.")

    if checked_files == 0:
        results["현황"].append("검사할 파일이 없습니다.")

    return results

def main():
    umask_settings_check_results = check_umask_settings()
    print(json.dumps(umask_settings_check_results, ensure_ascii=False, indent=4))

if __name__ == "__main__":
    main()

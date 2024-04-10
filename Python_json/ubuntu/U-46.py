#!/usr/bin/python3
import os
import json
import re

def get_min_length_from_line(line, setting_key):
    pattern = re.compile(r'\b' + re.escape(setting_key) + r'\b.*?(\d+)')
    match = pattern.search(line)
    if match:
        return int(match.group(1))
    return None

def check_password_min_length():
    results = {
        "분류": "계정관리",
        "코드": "U-46",
        "위험도": "중",
        "진단 항목": "패스워드 최소 길이 설정",
        "진단 결과": None,  # 초기 상태 설정, 검사 후 결과에 따라 업데이트
        "현황": [],
        "대응방안": "패스워드 최소 길이 8자 이상으로 설정"
    }

    files_to_check = [
        ("/etc/login.defs", "PASS_MIN_LEN", 8),
        ("/etc/pam.d/system-auth", "minlen", 8),
        ("/etc/pam.d/password-auth", "minlen", 8),
        ("/etc/security/pwquality.conf", "minlen", 8)
    ]

    for file_path, setting_key, expected_min_length in files_to_check:
        if os.path.isfile(file_path):
            with open(file_path, 'r') as file:
                found_setting = False
                for line in file:
                    if setting_key in line and not line.strip().startswith("#"):
                        found_setting = True
                        min_length = get_min_length_from_line(line, setting_key)
                        if min_length is None or min_length < expected_min_length:
                            results["진단 결과"] = "취약"
                            results["현황"].append(f"{file_path} 파일에서 {setting_key} 설정이 {expected_min_length}자 미만으로 설정되어 있습니다.")
                            break
                if not found_setting:
                    results["진단 결과"] = "취약"
                    results["현황"].append(f"{file_path} 파일에 {setting_key} 설정이 존재하지 않습니다.")
        else:
            results["진단 결과"] = "오류"
            results["현황"].append(f"{file_path} 파일이 존재하지 않습니다.")

    return results

def main():
    password_min_length_check_results = check_password_min_length()
    print(json.dumps(password_min_length_check_results, ensure_ascii=False, indent=4))

if __name__ == "__main__":
    main()

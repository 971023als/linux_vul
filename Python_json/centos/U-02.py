#!/usr/bin/python3
import os
import json
import re

def check_password_complexity():
    results = {
        "분류": "계정 관리",
        "코드": "U-02",
        "위험도": "상",
        "진단 항목": "패스워드 복잡성 설정",
        "진단 결과": "",
        "현황": [],
        "대응방안": "패스워드 최소길이 8자리 이상, 영문·숫자·특수문자 최소 입력 기능 설정"
    }

    min_length = 8
    min_input_requirements = {
        "lcredit": -1,  # Lowercase letters
        "ucredit": -1,  # Uppercase letters
        "dcredit": -1,  # Digits
        "ocredit": -1   # Special characters
    }
    files_to_check = [
        "/etc/login.defs",
        "/etc/pam.d/system-auth",
        "/etc/pam.d/password-auth",
        "/etc/security/pwquality.conf"
    ]
    password_settings_found = False

    for file_path in files_to_check:
        if os.path.exists(file_path):
            with open(file_path, "r", encoding='utf-8') as file:
                for line in file:
                    line = line.strip()
                    if not line.startswith("#") and line != "":
                        if "PASS_MIN_LEN" in line or "minlen" in line:
                            password_settings_found = True
                            value = int(re.search(r'\d+', line).group())
                            if value < min_length:
                                results["현황"].append(f"{file_path}: 설정된 패스워드 최소 길이 {value}자는 요구 사항 {min_length}자 미만입니다.")
                        for key, required_value in min_input_requirements.items():
                            if key in line:
                                password_settings_found = True
                                value = int(re.search(r'-?\d+', line.split(key)[1]).group())
                                if value < required_value:
                                    results["현황"].append(f"{file_path}: {key} 설정이 요구되는 {required_value}보다 낮은 {value}로 설정되어 있습니다.")

    if password_settings_found:
        results["진단 결과"] = "양호" if not results["현황"] else "취약"
    else:
        results["진단 결과"] = "취약"
        results["현황"].append("적절한 패스워드 복잡성 설정이 발견되지 않았습니다.")

    return results

def main():
    results = check_password_complexity()
    print(json.dumps(results, ensure_ascii=False, indent=4))

if __name__ == "__main__":
    main()

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
        "진단 결과": "취약",  # 초기값을 "취약"으로 설정
        "현황": [],
        "대응방안": "패스워드 최소길이 8자리 이상, 영문·숫자·특수문자 최소 입력 기능 설정"
    }

    configuration_status = {
        "min_length_set": False,
        "complexity_requirements_met": True
    }

    files_to_check = [
        "/etc/login.defs",
        "/etc/pam.d/system-auth",
        "/etc/pam.d/password-auth",
        "/etc/security/pwquality.conf"
    ]

    for file_path in files_to_check:
        if os.path.exists(file_path):
            with open(file_path, "r", encoding='utf-8') as file:
                file_content = file.read()
                # Check for minimum length setting
                minlen_matches = re.findall(r'(?i)(PASS_MIN_LEN\s+\d+|minlen=\d+)', file_content)
                if minlen_matches:
                    for match in minlen_matches:
                        value = int(re.search(r'\d+', match).group())
                        if value >= 8:
                            configuration_status["min_length_set"] = True
                        else:
                            results["현황"].append(f"{file_path}에서 패스워드 최소 길이가 권장치(8자) 미만으로 설정되어 있습니다.")
                
                # Check for complexity requirements
                for key in ["lcredit", "ucredit", "dcredit", "ocredit"]:
                    if re.search(fr'(?i){key}=-?\d+', file_content):
                        configuration_status["complexity_requirements_met"] &= True
                    else:
                        configuration_status["complexity_requirements_met"] = False
                        results["현황"].append(f"{file_path}에서 {key} 설정이 없어 패스워드 복잡성 요구사항을 충족하지 않습니다.")

    if configuration_status["min_length_set"] and configuration_status["complexity_requirements_met"]:
        results["진단 결과"] = "양호"
        results["현황"].append("패스워드 복잡성 설정이 적절히 구성되어 있습니다.")
    elif not results["현황"]:
        results["현황"].append("패스워드 복잡성 관련 설정을 찾을 수 없습니다.")

    return results

def main():
    results = check_password_complexity()
    print(json.dumps(results, ensure_ascii=False, indent=4))

if __name__ == "__main__":
    main()

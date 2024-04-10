#!/usr/bin/python3
import os
import json
import re

def check_account_lockout_threshold():
    results = {
        "분류": "계정 관리",
        "코드": "U-03",
        "위험도": "상",
        "진단 항목": "계정 잠금 임계값 설정",
        "진단 결과": "",
        "현황": [],
        "대응방안": "계정 잠금 임계값을 10회 이하로 설정"
    }

    files_to_check = [
        "/etc/pam.d/system-auth",
        "/etc/pam.d/password-auth"
    ]
    deny_modules = ["pam_tally2.so", "pam_faillock.so"]

    appropriate_settings = 0
    inappropriate_settings = 0

    for file_path in files_to_check:
        file_checked = False
        if os.path.exists(file_path):
            with open(file_path, "r", encoding='utf-8') as file:
                for line in file:
                    line = line.strip()
                    if not line.startswith("#") and "deny" in line:
                        file_checked = True
                        for deny_module in deny_modules:
                            if deny_module in line:
                                deny_value_matches = re.findall(r'deny=\d+', line)
                                if deny_value_matches:
                                    deny_value = int(deny_value_matches[0].split('=')[1])
                                    if deny_value <= 10:
                                        appropriate_settings += 1
                                    else:
                                        inappropriate_settings += 1
                                        results["현황"].append(f"{file_path}에서 {deny_module} 모듈의 계정 잠금 임계값이 {deny_value}회로 설정되어 있습니다. 권장 값은 10회 이하입니다.")
        if not file_checked:
            results["현황"].append(f"{file_path}에서 관련 설정을 찾을 수 없습니다.")

    if appropriate_settings == 0:
        results["진단 결과"] = "취약"
        if inappropriate_settings == 0:
            # 설정 자체가 발견되지 않은 경우
            results["현황"].append("계정 잠금 임계값을 설정하는 파일에서 관련 설정을 찾을 수 없습니다.")
        else:
            # 부적절한 설정만 발견된 경우
            results["현황"].append("모든 검사된 파일에서 계정 잠금 임계값 설정이 적절하지 않습니다.")
    else:
        results["진단 결과"] = "양호"

    return results

def main():
    results = check_account_lockout_threshold()
    print(json.dumps(results, ensure_ascii=False, indent=4))

if __name__ == "__main__":
    main()

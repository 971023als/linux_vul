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

    config_found = False
    threshold_appropriate = False

    for file_path in files_to_check:
        if os.path.exists(file_path):
            with open(file_path, "r", encoding='utf-8') as file:
                for line in file:
                    line = line.strip()
                    if not line.startswith("#") and "deny" in line:
                        config_found = True
                        for deny_module in deny_modules:
                            if deny_module in line:
                                deny_value_matches = re.findall(r'deny=\d+', line)
                                if deny_value_matches:
                                    deny_value = int(deny_value_matches[0].split('=')[1])
                                    if deny_value <= 10:
                                        threshold_appropriate = True
                                    else:
                                        results["현황"].append(f"{file_path}에서 {deny_module} 모듈의 계정 잠금 임계값이 {deny_value}회로 설정되어 있습니다. 권장 값은 10회 이하입니다.")

    if not config_found:
        results["현황"].append("계정 잠금 임계값을 설정하는 파일에서 관련 설정을 찾을 수 없습니다.")
        results["진단 결과"] = "취약"
    elif threshold_appropriate:
        results["진단 결과"] = "양호"
        results["현황"].append("모든 검사된 파일에서 계정 잠금 임계값이 적절히 설정되어 있습니다.")
    else:
        results["진단 결과"] = "취약"

    return results

def main():
    results = check_account_lockout_threshold()
    print(json.dumps(results, ensure_ascii=False, indent=4))

if __name__ == "__main__":
    main()

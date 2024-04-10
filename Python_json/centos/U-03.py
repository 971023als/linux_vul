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

    deny_files_checked = False
    account_lockout_threshold_set = False
    files_to_check = [
        "/etc/pam.d/system-auth",
        "/etc/pam.d/password-auth"
    ]
    deny_modules = ["pam_tally2.so", "pam_faillock.so"]

    for file_path in files_to_check:
        if os.path.exists(file_path):
            deny_files_checked = True
            with open(file_path, "r", encoding='utf-8') as file:  # 인코딩 명시
                for line in file:
                    line = line.strip()
                    if not line.startswith("#") and "deny" in line:
                        for deny_module in deny_modules:
                            if deny_module in line:
                                # Extract the deny value
                                deny_value_matches = re.findall(r'deny=[0-9]+', line)
                                if deny_value_matches:
                                    deny_value = int(deny_value_matches[0].split('=')[1])
                                    if deny_value <= 10:
                                        account_lockout_threshold_set = True
                                    else:
                                        results["현황"].append(f"{file_path}에서 설정된 계정 잠금 임계값이 10회를 초과합니다.")

    if not deny_files_checked:
        results["현황"].append("계정 잠금 임계값을 설정하는 파일을 찾을 수 없습니다.")
        results["진단 결과"] = "취약"
    elif not account_lockout_threshold_set:
        results["현황"].append("적절한 계정 잠금 임계값 설정이 없습니다.")
        results["진단 결과"] = "취약"
    else:
        results["현황"].append("계정 잠금 임계값이 적절히 설정되었습니다.")
        results["진단 결과"] = "양호"

    return results

def main():
    results = check_account_lockout_threshold()
    print(json.dumps(results, ensure_ascii=False, indent=4))

if __name__ == "__main__":
    main()

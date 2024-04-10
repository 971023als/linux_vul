#!/usr/bin/python3
import os
import subprocess
import json

def check_su_restriction():
    results = {
        "분류": "계정관리",
        "코드": "U-45",
        "위험도": "하",
        "진단 항목": "root 계정 su 제한",
        "진단 결과": "양호",  # Assume "Good" until proven otherwise
        "현황": [],
        "대응방안": "su 명령어 사용 특정 그룹 제한"
    }

    pam_su_path = "/etc/pam.d/su"
    if os.path.isfile(pam_su_path):
        with open(pam_su_path, 'r') as file:
            pam_contents = file.read()
            if 'pam_rootok.so' in pam_contents:
                if 'pam_wheel.so' not in pam_contents or 'auth required pam_wheel.so use_uid' not in pam_contents:
                    results["진단 결과"] = "취약"
                    results["현황"].append("/etc/pam.d/su 파일에 pam_wheel.so 모듈 설정이 적절히 구성되지 않았습니다.")
            else:
                results["진단 결과"] = "취약"
                results["현황"].append("/etc/pam.d/su 파일에서 pam_rootok.so 모듈이 누락되었습니다.")
    else:
        results["진단 결과"] = "취약"
        results["현황"].append("/etc/pam.d/su 파일이 존재하지 않습니다.")

    return results

def main():
    su_restriction_check_results = check_su_restriction()
    print(json.dumps(su_restriction_check_results, ensure_ascii=False, indent=4))

if __name__ == "__main__":
    main()

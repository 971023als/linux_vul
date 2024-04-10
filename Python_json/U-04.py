#!/usr/bin/python3
import os
import json

def check_shadow_password_usage():
    results = {
        "분류": "계정 관리",
        "코드": "U-04",
        "위험도": "상",
        "진단 항목": "패스워드 파일 보호",
        "진단 결과": "",
        "현황": [],
        "대응방안": "쉐도우 패스워드 사용 또는 패스워드 암호화 저장"
    }

    # /etc/passwd 파일에서 쉐도우 패스워드 사용 여부 확인
    passwd_file = "/etc/passwd"
    shadow_file = "/etc/shadow"
    shadow_used = True  # 가정: 쉐도우 패스워드 사용

    # /etc/passwd 파일 검사
    if os.path.exists(passwd_file):
        with open(passwd_file, "r", encoding='utf-8') as file:
            for line in file:
                parts = line.strip().split(":")
                if len(parts) > 1 and parts[1] != "x":
                    shadow_used = False
                    break

    # /etc/shadow 파일 존재 및 권한 검사
    if shadow_used and os.path.exists(shadow_file):
        mode = os.stat(shadow_file).st_mode
        if not (mode & 0o400):  # /etc/shadow가 읽기 전용으로 설정되어 있는지 확인
            results["현황"].append("/etc/shadow 파일이 안전한 권한 설정을 갖고 있지 않습니다.")
            shadow_used = False

    if not shadow_used:
        results["현황"].append("쉐도우 패스워드를 사용하고 있지 않거나 /etc/shadow 파일의 권한 설정이 적절하지 않습니다.")
        results["진단 결과"] = "취약"
    else:
        results["현황"].append("쉐도우 패스워드를 사용하고 있으며 /etc/shadow 파일의 권한 설정이 적절합니다.")
        results["진단 결과"] = "양호"

    return results

def main():
    results = check_shadow_password_usage()
    print(json.dumps(results, ensure_ascii=False, indent=4))

if __name__ == "__main__":
    main()

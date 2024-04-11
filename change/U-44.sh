#!/usr/bin/python3
import json

def check_for_non_root_uid_zero():
    results = {
        "분류": "계정관리",
        "코드": "U-44",
        "위험도": "중",
        "진단 항목": "root 이외의 UID가 '0' 금지",
        "진단 결과": "양호",  # Assume "Good" until proven otherwise
        "현황": [],
        "대응방안": "root 계정 외 UID 0 사용 금지"
    }

    with open('/etc/passwd', 'r') as passwd_file:
        for line in passwd_file:
            user_info = line.split(':')
            if user_info[2] == '0' and user_info[0] != 'root':
                results["진단 결과"] = "취약"
                results["현황"].append(f"root 계정과 동일한 UID(0)를 갖는 계정이 존재합니다: {user_info[0]}")
                break

    if results["진단 결과"] == "양호":
        results["현황"].append("root 계정 외에 UID 0을 갖는 계정이 존재하지 않습니다.")

    return results

def main():
    uid_zero_check_results = check_for_non_root_uid_zero()
    print(json.dumps(uid_zero_check_results, ensure_ascii=False, indent=4))

if __name__ == "__main__":
    main()

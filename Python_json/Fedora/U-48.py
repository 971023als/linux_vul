#!/usr/bin/python3
import os
import json  # Import the json module

def check_password_min_usage_period():
    results = {
        "분류": "계정관리",
        "코드": "U-48",
        "위험도": "중",
        "진단 항목": "패스워드 최소 사용기간 설정",
        "진단 결과": "양호",  # Assume "Good" until proven otherwise
        "현황": [],
        "대응방안": "패스워드 최소 사용기간 1일 이상으로 설정"
    }

    login_defs_path = "/etc/login.defs"
    if os.path.isfile(login_defs_path):
        with open(login_defs_path, 'r') as file:
            for line in file:
                if "PASS_MIN_DAYS" in line and not line.strip().startswith("#"):
                    min_days = line.split()[1]
                    if min_days.isdigit() and int(min_days) < 1:
                        results["진단 결과"] = "취약"
                        results["현황"].append(f"/etc/login.defs 파일에 패스워드 최소 사용 기간이 1일 미만으로 설정되어 있습니다.")
                    else:
                        # If PASS_MIN_DAYS is set to 1 or more, it's considered Good and we don't need to update anything.
                        pass
                    break
            else:
                # If PASS_MIN_DAYS is not found in the file
                results["진단 결과"] = "취약"
                results["현황"].append("/etc/login.defs 파일에 패스워드 최소 사용 기간이 설정되어 있지 않습니다.")
    else:
        results["진단 결과"] = "취약"
        results["현황"].append("/etc/login.defs 파일이 없습니다.")

    return results

def main():
    password_min_usage_period_check_results = check_password_min_usage_period()
    print(json.dumps(password_min_usage_period_check_results, ensure_ascii=False, indent=4))

if __name__ == "__main__":
    main()

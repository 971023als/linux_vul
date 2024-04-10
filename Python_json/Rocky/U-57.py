#!/usr/bin/python3
import os
import pwd
import json
import stat

def check_home_directory_ownership_and_permissions():
    results = {
        "분류": "파일 및 디렉토리 관리",
        "코드": "U-57",
        "위험도": "중",
        "진단 항목": "홈디렉토리 소유자 및 권한 설정",
        "진단 결과": "양호",  # Initially assume all is well
        "현황": [],
        "대응방안": "홈 디렉터리 소유자를 해당 계정으로 설정 및 타 사용자 쓰기 권한 제거"
    }

    try:
        users = pwd.getpwall()  # Get all user entries
        for user in users:
            # Skip system users by UID
            if user.pw_uid >= 1000:
                home_dir = user.pw_dir
                if os.path.isdir(home_dir):  # Ensure the home directory exists
                    stat_info = os.stat(home_dir)
                    if stat_info.st_uid != user.pw_uid:
                        results["현황"].append(f"{home_dir} 홈 디렉터리의 소유자가 {user.pw_name}이(가) 아닙니다.")
                        results["진단 결과"] = "취약"
                    if bool(stat_info.st_mode & stat.S_IWOTH):  # Check for other write permissions
                        results["현황"].append(f"{home_dir} 홈 디렉터리에 타 사용자(other) 쓰기 권한이 설정되어 있습니다.")
                        results["진단 결과"] = "취약"
                else:
                    results["현황"].append(f"{home_dir} 홈 디렉터리가 존재하지 않습니다.")
                    results["진단 결과"] = "취약"
    except Exception as e:
        results["진단 결과"] = "오류"
        results["현황"].append(f"홈 디렉터리 소유자 및 권한 설정 검사 중 예외가 발생했습니다: {str(e)}")

    return results

def main():
    home_dir_check_results = check_home_directory_ownership_and_permissions()
    print(json.dumps(home_dir_check_results, ensure_ascii=False, indent=4))

if __name__ == "__main__":
    main()

#!/usr/bin/python3
import os
import pwd
import stat
import json

def check_user_system_start_files():
    results = {
        "분류": "파일 및 디렉터리 관리",
        "코드": "U-14",
        "위험도": "상",
        "진단 항목": "사용자, 시스템 시작파일 및 환경파일 소유자 및 권한 설정",
        "진단 결과": "",  # 초기 진단 결과 설정하지 않음
        "현황": [],
        "대응방안": "홈 디렉터리 환경변수 파일 소유자가 root 또는 해당 계정으로 지정되어 있고, 쓰기 권한이 부여된 경우"
    }

    start_files = [".profile", ".cshrc", ".login", ".kshrc", ".bash_profile", ".bashrc", ".bash_login"]
    vulnerable_files = []

    # 모든 사용자 홈 디렉터리 가져오기
    user_homes = [user.pw_dir for user in pwd.getpwall() if os.path.isdir(user.pw_dir)]

    for home in user_homes:
        for start_file in start_files:
            file_path = os.path.join(home, start_file)
            if os.path.isfile(file_path):
                file_stat = os.stat(file_path)
                mode = file_stat.st_mode

                # 파일 소유자가 root 또는 해당 사용자가 아니거나, 다른 사용자에게 쓰기 권한이 있을 경우
                if not (file_stat.st_uid == 0 or file_stat.st_uid == pwd.getpwnam(os.path.basename(home)).pw_uid) or (mode & stat.S_IWOTH):
                    vulnerable_files.append(file_path)

    if vulnerable_files:
        results["진단 결과"] = "취약"
        results["현황"] = vulnerable_files
    else:
        results["진단 결과"] = "양호"
        results["현황"].append("모든 홈 디렉터리 내 시작파일 및 환경파일이 적절한 소유자와 권한 설정을 가지고 있습니다.")

    return results

def main():
    user_system_start_files_check_results = check_user_system_start_files()
    print(json.dumps(user_system_start_files_check_results, ensure_ascii=False, indent=4))

if __name__ == "__main__":
    main()

#!/usr/bin/python3
import subprocess
import os
import json

def check_unnecessary_web_files_removal():
    results = {
        "분류": "서비스 관리",
        "코드": "U-38",
        "위험도": "상",
        "진단 항목": "웹서비스 불필요한 파일 제거",
        "진단 결과": None,  # 초기 상태 설정, 검사 후 결과에 따라 업데이트
        "현황": [],
        "대응방안": "기본으로 생성되는 불필요한 파일 및 디렉터리 제거"
    }

    webconf_files = [".htaccess", "httpd.conf", "apache2.conf"]
    serverroot_directories = []

    for conf_file in webconf_files:
        find_command = f"find / -name {conf_file} -type f 2>/dev/null"
        try:
            find_output = subprocess.check_output(find_command, shell=True, text=True).strip().split('\n')
            for file_path in find_output:
                if file_path:
                    with open(file_path, 'r') as file:
                        for line in file:
                            if 'ServerRoot' in line and not line.strip().startswith('#'):
                                serverroot = line.split()[1].strip('"')
                                if serverroot not in serverroot_directories:
                                    serverroot_directories.append(serverroot)
        except subprocess.CalledProcessError:
            continue  # find 명령어 실행 중 오류가 발생하면 다음 파일로 넘어감

    vulnerable = False
    for directory in serverroot_directories:
        manual_path = os.path.join(directory, 'manual')
        if os.path.exists(manual_path):
            results["진단 결과"] = "취약"
            results["현황"].append(f"Apache 홈 디렉터리 내 기본으로 생성되는 불필요한 파일 및 디렉터리가 제거되어 있지 않습니다: {manual_path}")
            vulnerable = True

    if not vulnerable:
        results["진단 결과"] = "양호"
        results["현황"].append("Apache 홈 디렉터리 내 기본으로 생성되는 불필요한 파일 및 디렉터리가 제거되어 있습니다.")

    return results

def main():
    results = check_unnecessary_web_files_removal()
    print(json.dumps(results, ensure_ascii=False, indent=4))

if __name__ == "__main__":
    main()

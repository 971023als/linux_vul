#!/usr/bin/python3
import subprocess
import os
import json

def check_web_directory_access_restriction():
    results = {
        "분류": "서비스 관리",
        "코드": "U-37",
        "위험도": "상",
        "진단 항목": "웹서비스 상위 디렉토리 접근 금지",
        "진단 결과": None,  # 초기 상태 설정, 검사 후 결과에 따라 업데이트
        "현황": [],
        "대응방안": "상위 디렉터리에 이동제한 설정"
    }

    webconf_files = [".htaccess", "httpd.conf", "apache2.conf", "userdir.conf"]
    found_vulnerability = False

    for conf_file in webconf_files:
        find_command = f"find / -name {conf_file} -type f 2>/dev/null"
        try:
            find_output = subprocess.check_output(find_command, shell=True, text=True).strip().split('\n')
            for file_path in find_output:
                if file_path:
                    with open(file_path, 'r') as file:
                        content = file.read()
                        if 'AllowOverride None' not in content:
                            found_vulnerability = True
                            results["진단 결과"] = "취약"
                            results["현황"].append(f"{file_path} 파일에 상위 디렉터리 접근 제한 설정이 없습니다.")
                            break
        except subprocess.CalledProcessError:
            continue  # find 명령어 실행 중 오류가 발생하면 다음 파일로 넘어감

    if not found_vulnerability:
        results["진단 결과"] = "양호"
        results["현황"].append("웹서비스 상위 디렉터리 접근에 대한 제한이 적절히 설정되어 있습니다.")

    return results

def main():
    results = check_web_directory_access_restriction()
    print(json.dumps(results, ensure_ascii=False, indent=4))

if __name__ == "__main__":
    main()

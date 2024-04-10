#!/usr/bin/python3
import subprocess
import os
import json

def check_web_service_directory_listing():
    results = {
        "분류": "서비스 관리",
        "코드": "U-35",
        "위험도": "상",
        "진단 항목": "웹서비스 디렉토리 리스팅 제거",
        "진단 결과": None,  # 초기 상태 설정, 검사 후 결과에 따라 업데이트
        "현황": [],
        "대응방안": "디렉터리 검색 기능 사용하지 않기"
    }

    webconf_files = [".htaccess", "httpd.conf", "apache2.conf", "userdir.conf"]
    vulnerable = False

    for conf_file in webconf_files:
        # 시스템에서 웹 구성 파일 찾기
        find_command = f"find / -name {conf_file} -type f 2>/dev/null"
        try:
            find_output = subprocess.check_output(find_command, shell=True, text=True).strip().split('\n')
            for file_path in find_output:
                if file_path:
                    with open(file_path, 'r') as file:
                        content = file.read()
                        if "userdir.conf" in file_path:
                            if "userdir disabled" not in content.lower() and "options indexes" in content.lower() and "-indexes" not in content.lower():
                                vulnerable = True
                        else:
                            if "options indexes" in content.lower() and "-indexes" not in content.lower():
                                vulnerable = True
                        if vulnerable:
                            results["진단 결과"] = "취약"
                            results["현황"].append(f"{file_path} 파일에 디렉터리 검색 기능을 사용하도록 설정되어 있습니다.")
                            break
        except subprocess.CalledProcessError:
            continue  # find 명령어 실행 중 오류가 발생하면 다음 파일로 넘어감

    if not vulnerable:
        results["진단 결과"] = "양호"
        results["현황"].append("웹서비스 디렉터리 리스팅이 적절히 제거되었습니다.")

    return results

def main():
    results = check_web_service_directory_listing()
    print(json.dumps(results, ensure_ascii=False, indent=4))

if __name__ == "__main__":
    main()

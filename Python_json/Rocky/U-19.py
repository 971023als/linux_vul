#!/usr/bin/python3
import subprocess
import re
import json

def check_finger_service_disabled():
    results = {
        "분류": "서비스 관리",
        "코드": "U-19",
        "위험도": "상",
        "진단 항목": "Finger 서비스 비활성화",
        "진단 결과": None,  # 초기 상태 설정, 결과에 따라 업데이트 예정
        "현황": [],
        "대응방안": "Finger 서비스가 비활성화 되어 있는 경우"
    }

    # /etc/services에서 Finger 서비스 정의 확인
    try:
        with open('/etc/services', 'r') as services_file:
            services_contents = services_file.read()
            if re.search(r'^finger.*tcp', services_contents, re.MULTILINE | re.IGNORECASE):
                results["현황"].append("Finger 서비스 포트가 /etc/services에 정의되어 있습니다.")
                results["진단 결과"] = "취약"
    except FileNotFoundError:
        results["현황"].append("/etc/services 파일을 찾을 수 없습니다.")

    # Finger 프로세스 실행 중인지 확인
    ps_output = subprocess.run(['ps', '-ef'], stdout=subprocess.PIPE, universal_newlines=True).stdout
    if 'finger' in ps_output.lower():
        results["현황"].append("Finger 서비스 프로세스가 실행 중입니다.")
        results["진단 결과"] = "취약"

    if not results["진단 결과"]:
        results["진단 결과"] = "양호"
        results["현황"].append("Finger 서비스가 비활성화되어 있거나 실행 중이지 않습니다.")

    return results

def main():
    results = check_finger_service_disabled()
    print(json.dumps(results, ensure_ascii=False, indent=4))

if __name__ == "__main__":
    main()

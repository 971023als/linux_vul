#!/usr/bin/python3
import os
import re
import json

def check_tftp_talk_services_disabled():
    results = {
        "분류": "서비스 관리",
        "코드": "U-29",
        "위험도": "상",
        "진단 항목": "tftp, talk 서비스 비활성화",
        "진단 결과": None,  # 초기 상태 설정, 검사 후 결과에 따라 업데이트
        "현황": [],
        "대응방안": "tftp, talk, ntalk 서비스 비활성화"
    }

    services = ["tftp", "talk", "ntalk"]
    xinetd_dir = "/etc/xinetd.d"
    inetd_conf = "/etc/inetd.conf"
    service_found = False

    # /etc/xinetd.d 디렉터리 내 서비스 검사
    if os.path.isdir(xinetd_dir):
        for service in services:
            service_path = os.path.join(xinetd_dir, service)
            if os.path.isfile(service_path):
                with open(service_path, 'r') as file:
                    content = file.read()
                    if 'disable = yes' not in content:
                        results["진단 결과"] = "취약"
                        results["현황"].append(f"{service} 서비스가 /etc/xinetd.d 디렉터리 내 서비스 파일에서 실행 중입니다.")
                        service_found = True

    # /etc/inetd.conf 파일 내 서비스 검사
    if os.path.isfile(inetd_conf):
        with open(inetd_conf, 'r') as file:
            content = file.read()
            for service in services:
                if re.search(f"^{service}\s", content, re.MULTILINE):
                    results["진단 결과"] = "취약"
                    results["현황"].append(f"{service} 서비스가 /etc/inetd.conf 파일에서 실행 중입니다.")
                    service_found = True

    if not service_found:
        results["진단 결과"] = "양호"
        results["현황"].append("tftp, talk, ntalk 서비스가 모두 비활성화되어 있습니다.")

    return results

def main():
    results = check_tftp_talk_services_disabled()
    print(json.dumps(results, ensure_ascii=False, indent=4))

if __name__ == "__main__":
    main()

#!/usr/bin/python3
import subprocess
import json
import os  # Necessary module import added

def check_dns_zone_transfer_settings():
    results = {
        "분류": "서비스 관리",
        "코드": "U-34",
        "위험도": "상",
        "진단 항목": "DNS Zone Transfer 설정",
        "진단 결과": "양호",  # 초기 상태를 '양호'로 가정
        "현황": [],
        "대응방안": "Zone Transfer를 허가된 사용자에게만 허용"
    }

    named_conf_path = "/etc/named.conf"

    # Check if DNS service is running
    try:
        ps_output = subprocess.check_output("ps -ef | grep -i 'named' | grep -v 'grep'", shell=True, universal_newlines=True).strip()
        dns_service_running = bool(ps_output)
    except subprocess.CalledProcessError:
        dns_service_running = False

    if dns_service_running:
        if os.path.isfile(named_conf_path):
            with open(named_conf_path, 'r') as file:
                named_conf_contents = file.read()
                if "allow-transfer { any; }" in named_conf_contents:
                    results["진단 결과"] = "취약"
                    results["현황"].append("/etc/named.conf 파일에 allow-transfer { any; } 설정이 있습니다.")
                else:
                    results["현황"].append("DNS Zone Transfer가 허가된 사용자에게만 허용되어 있습니다.")
        else:
            results["현황"].append("/etc/named.conf 파일이 존재하지 않습니다. DNS 서비스 미사용 가능성.")
    else:
        results["현황"].append("DNS 서비스가 실행 중이지 않습니다.")

    return results

def main():
    results = check_dns_zone_transfer_settings()
    print(json.dumps(results, ensure_ascii=False, indent=4))

if __name__ == "__main__":
    main()

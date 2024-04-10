#!/usr/bin/python3
import subprocess
import json

def check_snmp_service_usage():
    results = {
        "분류": "서비스 관리",
        "코드": "U-66",
        "위험도": "중",
        "진단 항목": "SNMP 서비스 구동 점검",
        "진단 결과": "",
        "현황": "",
        "대응방안": "SNMP 서비스 사용을 필요로 하지 않는 경우, 서비스를 비활성화"
    }

    # Adjusted to use universal_newlines=True for compatibility with Python 3.6
    process = subprocess.run(['ps', '-ef'], stdout=subprocess.PIPE, universal_newlines=True)
    if 'snmp' in process.stdout.lower():
        results["진단 결과"] = "취약"
        results["현황"] = "SNMP 서비스를 사용하고 있습니다."
    else:
        results["진단 결과"] = "양호"
        results["현황"] = "SNMP 서비스를 사용하지 않고 있습니다."

    return results

def main():
    snmp_service_check_results = check_snmp_service_usage()
    print(json.dumps(snmp_service_check_results, ensure_ascii=False, indent=4))

if __name__ == "__main__":
    main()

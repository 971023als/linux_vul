#!/usr/bin/python3
import subprocess
import re
import json

def check_snmp_community_string_complexity():
    results = {
        "분류": "서비스 관리",
        "코드": "U-67",
        "위험도": "중",
        "진단 항목": "SNMP 서비스 Community String의 복잡성 설정",
        "진단 결과": "",
        "현황": "",
        "대응방안": "SNMP Community 이름이 public, private이 아닌 경우"
    }

    # Check if SNMP service is running, using universal_newlines for compatibility
    ps_output = subprocess.run(['ps', '-ef'], stdout=subprocess.PIPE, universal_newlines=True).stdout
    if 'snmp' not in ps_output.lower():
        results["진단 결과"] = "양호"
        results["현황"] = "SNMP 서비스를 사용하지 않고 있습니다."
        return results

    # Search for snmpd.conf files
    find_command = ['find', '/', '-name', 'snmpd.conf', '-type', 'f']
    find_result = subprocess.run(find_command, stdout=subprocess.PIPE, universal_newlines=True, stderr=subprocess.DEVNULL)
    snmpdconf_files = find_result.stdout.strip().split('\n')

    weak_string_found = False

    if not snmpdconf_files or snmpdconf_files == ['']:
        results["진단 결과"] = "취약"
        results["현황"] = "SNMP 서비스를 사용하고 있으나, Community String을 설정하는 파일이 없습니다."
    else:
        for file_path in snmpdconf_files:
            try:
                with open(file_path, 'r') as file:
                    file_content = file.read()
                    if re.search(r'\b(public|private)\b', file_content, re.IGNORECASE):
                        weak_string_found = True
                        results["진단 결과"] = "취약"
                        results["현황"] = f"SNMP Community String이 취약(public 또는 private)으로 설정되어 있습니다. 파일: {file_path}"
                        break
            except Exception as e:
                continue

    if not weak_string_found and snmpdconf_files != ['']:
        results["진단 결과"] = "양호"
        results["현황"] = "SNMP Community String이 적절히 설정되어 있습니다."

    return results

def main():
    snmp_community_string_complexity_check_results = check_snmp_community_string_complexity()
    print(json.dumps(snmp_community_string_complexity_check_results, ensure_ascii=False, indent=4))

if __name__ == "__main__":
    main()

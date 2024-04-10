#!/usr/bin/python3
import subprocess
import re
import json

def check_apache_info_hiding():
    results = {
        "분류": "서비스 관리",
        "코드": "U-71",
        "위험도": "중",
        "진단 항목": "Apache 웹 서비스 정보 숨김",
        "진단 결과": "",  # 초기 진단 결과 설정하지 않음
        "현황": "",
        "대응방안": "ServerTokens Prod, ServerSignature Off로 설정"
    }

    webconf_files = [".htaccess", "httpd.conf", "apache2.conf"]
    configuration_set_correctly = False
    
    for conf_file in webconf_files:
        find_command = ['find', '/', '-name', conf_file, '-type', 'f']
        find_result = subprocess.run(find_command, stdout=subprocess.PIPE, text=True, stderr=subprocess.DEVNULL)
        conf_paths = find_result.stdout.strip().split('\n')
        
        for path in conf_paths:
            if path:
                with open(path, 'r') as file:
                    content = file.read()
                    server_tokens = re.search(r'^\s*ServerTokens\s+Prod', content, re.MULTILINE | re.IGNORECASE)
                    server_signature = re.search(r'^\s*ServerSignature\s+Off', content, re.MULTILINE | re.IGNORECASE)
                    if server_tokens and server_signature:
                        configuration_set_correctly = True
                        break  # Found at least one config set correctly, no need to mark as vulnerable yet

    if configuration_set_correctly:
        results["진단 결과"] = "양호"
        results["현황"] = "Apache 설정이 적절히 설정되어 있습니다."
    else:
        ps_apache_count = subprocess.run(['pgrep', '-f', 'apache2|httpd'], stdout=subprocess.PIPE, text=True).stdout
        if ps_apache_count:
            results["진단 결과"] = "취약"
            results["현황"] = "Apache 서비스를 사용하고 있으나, ServerTokens Prod, ServerSignature Off 설정이 적절히 구성되어 있지 않습니다."

    return results

def main():
    apache_info_hiding_check_results = check_apache_info_hiding()
    print(json.dumps(apache_info_hiding_check_results, ensure_ascii=False, indent=4))

if __name__ == "__main__":
    main()

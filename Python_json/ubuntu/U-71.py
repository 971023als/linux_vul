#!/usr/bin/python3
import subprocess
import re
import json


def print_as_md(results: dict):
    """진단 결과를 Markdown 테이블 형식으로 출력."""
    code   = results.get("코드",     results.get("code", "U-??"))
    item   = results.get("진단 항목", results.get("diagnosisItem", "진단항목"))
    cat    = results.get("분류",     results.get("category", ""))
    risk   = results.get("위험도",   results.get("riskLevel", ""))
    result = results.get("진단 결과", results.get("diagnosisResult", ""))
    status = results.get("현황",     results.get("status", []))
    sol    = results.get("대응방안", results.get("solution", ""))

    if isinstance(status, list):
        status = " / ".join(status) if status else ""

    print(f"# {code}: {item}")
    print("")
    print("| 항목 | 내용 |")
    print("|------|------|")
    print(f"| 분류 | {cat} |")
    print(f"| 코드 | {code} |")
    print(f"| 위험도 | {risk} |")
    print(f"| 진단항목 | {item} |")
    print(f"| 진단결과 | {result} |")
    print(f"| 현황 | {status} |")
    print(f"| 대응방안 | {sol} |")


# Mapping of web servers to their configuration files and information hiding directives
web_servers = {
    'Apache': {
        'config_files': ['httpd.conf', 'apache2.conf', '.htaccess'],
        'directives': [
            {'directive': 'ServerTokens', 'expected_value': 'Prod'},
            {'directive': 'ServerSignature', 'expected_value': 'Off'}
        ]
    },
    'Nginx': {
        'config_files': ['nginx.conf'],
        'directives': [
            {'directive': 'server_tokens', 'expected_value': 'off'}
        ]
    },
    'LiteSpeed': {
        'config_files': ['httpd_config.conf'],
        'directives': [
            # LiteSpeed supports Apache's .htaccess directives but documentation should be consulted for specifics
            {'directive': 'ServerTokens', 'expected_value': 'Prod'},
            {'directive': 'ServerSignature', 'expected_value': 'Off'}
        ]
    },
    'Microsoft-IIS': {
        # IIS uses different mechanisms, typically managed through the IIS Manager or PowerShell
        'config_files': [],
        'directives': [
            # Example PowerShell command to hide IIS version
            {'directive': 'Use URL Rewrite to remove Server header', 'expected_value': 'Server header removed'}
        ]
    },
    'Node.js': {
        # Node.js server headers are usually managed in the application code
        'config_files': [],
        'directives': [
            {'directive': 'Set custom Server header in response', 'expected_value': 'Custom Server header value'}
        ]
    },
    'Envoy': {
        'config_files': ['envoy.yaml'],
        'directives': [
            {'directive': 'server_name', 'expected_value': 'Custom Server Name'}
        ]
    },
    'Caddy': {
        'config_files': ['Caddyfile'],
        'directives': [
            {'directive': 'header', 'expected_value': '-Server'}
        ]
    },
    'Tomcat': {
        'config_files': ['server.xml', 'web.xml'],
        'directives': [
            # In Tomcat, server information can be customized in the Connector configuration in server.xml
            {'directive': 'server', 'expected_value': 'Custom Server Name'},
            # Use Valve component to filter or modify headers
            {'directive': 'Header', 'expected_value': 'Remove Server header'}
        ]
    }
    # Additional web servers could be added here.
}


def check_information_hiding(server_info):
    configuration_set_correctly = False
    for conf_file in server_info['config_files']:
        find_command = ['find', '/', '-name', conf_file, '-type', 'f']
        # Adjusted for compatibility with Python versions before 3.7
        find_result = subprocess.run(find_command, stdout=subprocess.PIPE, universal_newlines=True, stderr=subprocess.DEVNULL)
        conf_paths = find_result.stdout.strip().split('\n')

        for path in conf_paths:
            if path:
                try:
                    with open(path, 'r') as file:
                        content = file.read()
                        all_directives_correct = True
                        for directive in server_info['directives']:
                            # Corrected the regex pattern to properly format the directive and expected value
                            directive_pattern = r'{}\s+{}'.format(directive['directive'], directive['expected_value'])
                            if not re.search(directive_pattern, content, re.MULTILINE | re.IGNORECASE):
                                all_directives_correct = False
                                break
                        if all_directives_correct:
                            configuration_set_correctly = True
                            return True  # Correct configuration found, no need to check further
                except IOError as e:
                    # Handle possible file access errors
                    continue
    return configuration_set_correctly

def main():
    results = {
        "분류": "서비스 관리",
        "코드": "U-71",
        "위험도": "중",
        "진단 항목": "웹 서비스 정보 숨김",
        "진단 결과": "",
        "현황": "",
        "대응방안": "웹 서버 정보 숨김 설정 적용"
    }

    overall_configuration_set_correctly = False

    for server_name, server_info in web_servers.items():
        configuration_set_correctly = check_information_hiding(server_info)
        overall_configuration_set_correctly |= configuration_set_correctly

        if configuration_set_correctly:
            results["현황"] += f"{server_name} 설정이 적절히 설정되어 있습니다. "
    
    if overall_configuration_set_correctly:
        results["진단 결과"] = "양호"
    else:
        results["진단 결과"] = "취약"
        results["현황"] += f"{server_name} 웹 서버에서 정보 숨김 설정이 적절히 구성되어 있지 않습니다."

    print_as_md(results)

if __name__ == "__main__":
    main()

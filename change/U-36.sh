#!/usr/bin/python3
import os
import subprocess
import re
import json

web_servers = {
    'Apache': {
        'process_name': 'httpd',
        'config_files': ['httpd.conf', 'apache2.conf'],
        'user_directive': 'User',
        'group_directive': 'Group'
    },
    'Nginx': {
        'process_name': 'nginx',
        'config_files': ['nginx.conf'],
        'user_directive': 'user',
    },
    'LiteSpeed': {
        'process_name': 'lshttpd',
        'config_files': ['httpd_config.conf'],
        'user_directive': 'User',
        'group_directive': 'Group'
    },
    'Microsoft-IIS': {
        # IIS uses Windows services and management consoles rather than process names and config files in the traditional sense
        'service_name': 'W3SVC',
        'management_console': 'inetmgr',
        # Permissions are typically handled through Windows user accounts and ACLs
    },
    'Node.js': {
        'process_name': 'node',
        # Configuration is often project-specific and not standardized
    },
    'Envoy': {
        'process_name': 'envoy',
        'config_files': ['envoy.yaml'],
        # User/group directives are not typically used; runtime permissions are determined by the process executor
    },
    'Caddy': {
        'process_name': 'caddy',
        'config_files': ['Caddyfile'],
        # User/group directives are not typically used; runtime permissions are determined by the process executor
    },
    'Tomcat': {
        'process_name': 'java',  # Since Tomcat runs on the JVM, the process name is usually 'java'
        'config_files': ['server.xml', 'web.xml'],
        'user_directive': 'tomcat',  # Not a directive, but Tomcat often runs under a 'tomcat' user for security
    }
    # Additional web servers could be added here.
}


def find_config_files(config_files):
    found_files = []
    for conf_file in config_files:
        find_command = f"find / -name {conf_file} -type f 2>/dev/null"
        try:
            find_output = subprocess.check_output(find_command, shell=True, universal_newlines=True).strip().split('\n')
            found_files.extend(find_output)
        except subprocess.CalledProcessError:
            continue
    return found_files

def check_permissions(server_info, found_files):
    vulnerable = False
    vulnerabilities = []

    user_regex = re.compile(r'^\s*' + re.escape(server_info.get('user_directive', '')) + r'\s+([\w-]+)', re.IGNORECASE)
    group_regex = re.compile(r'^\s*' + re.escape(server_info.get('group_directive', '')) + r'\s+([\w-]+)', re.IGNORECASE)

    for file_path in found_files:
        if file_path:
            try:
                with open(file_path, 'r') as file:
                    for line in file:
                        user_match = user_regex.match(line)
                        if user_match and user_match.group(1).lower() == 'root':
                            vulnerable = True
                            vulnerabilities.append((file_path, 'user', user_match.group(1)))

                        group_match = group_regex.match(line)
                        if group_match and group_match.group(1).lower() == 'root':
                            vulnerable = True
                            vulnerabilities.append((file_path, 'group', group_match.group(1)))
            except FileNotFoundError:
                continue

    return vulnerable, vulnerabilities

def main():
    results = {
        "분류": "서비스 관리",
        "코드": "U-36",
        "위험도": "상",
        "진단 항목": "웹서비스 웹 프로세스 권한 제한",
        "진단 결과": None,
        "현황": [],
        "대응방안": "웹서버 프로세스의 권한을 적절히 제한하기"
    }

    overall_vulnerable = False

    for server_name, server_info in web_servers.items():
        if 'config_files' in server_info:
            found_files = find_config_files(server_info['config_files'])
            vulnerable, vulnerabilities = check_permissions(server_info, found_files)
            if vulnerable:
                overall_vulnerable = True
                for vulnerability in vulnerabilities:
                    results["현황"].append(f"{vulnerability[0]} 파일에서 {server_name} 데몬이 {vulnerability[1]} '{vulnerability[2]}'으로 설정되어 있습니다.")
        else:
            # Perhaps handle servers without config_files differently or log a message
            pass

    if overall_vulnerable:
        results["진단 결과"] = "취약"
    else:
        results["진단 결과"] = "양호"
        # Update this line to provide a general message without referencing 'vulnerability'
        results["현황"].append("모든 검사된 서버 데몬들이 적절히 권한 제한이 되어 있습니다.")

    print(json.dumps(results, ensure_ascii=False, indent=4))

if __name__ == "__main__":
    main()

#!/usr/bin/python3
import os
import re
import json
import subprocess

# Define a dictionary mapping web server types to their process names and commands for checking version and configuration
web_servers = {
    'Apache': {
        'process_name': 'httpd',
        'version_command': '-V',
        'config_command': '-V',
        'config_files': ['.htaccess', 'httpd.conf', 'apache2.conf']
    },
    'Nginx': {
        'process_name': 'nginx',
        'version_command': '-v',
        'config_command': '-T',
        'config_files': ['nginx.conf']
    },
    'LiteSpeed': {
        'process_name': 'litespeed',
        'version_command': '-v',  # Placeholder, may need to check documentation
        'config_command': '-T',  # Placeholder, may need to check documentation
        'config_files': ['httpd_config.conf']
    },
    'Microsoft-IIS': {
        # IIS uses a different management style, these placeholders might not apply
        'process_name': 'w3wp.exe',
        'version_command': '',  # Managed through Windows Features or PowerShell
        'config_command': '',  # Managed through Internet Information Services (IIS) Manager
        'config_files': ['applicationHost.config']  # Location varies, often in %windir%\system32\inetsrv\
    },
    'Node.js': {
        'process_name': 'node',
        'version_command': '-v',
        'config_command': '',  # Configuration is often through environment variables or within the application
        'config_files': ['package.json', '.env']  # Common files, actual configuration depends on the application
    },
    'Envoy': {
        'process_name': 'envoy',
        'version_command': '--version',
        'config_command': '-c',  # Used with the path to a configuration file to start Envoy
        'config_files': ['envoy.yaml']
    },
    'Caddy': {
        'process_name': 'caddy',
        'version_command': 'version',
        'config_command': 'validate',  # To validate the Caddyfile configuration
        'config_files': ['Caddyfile']
    },
    'Tomcat': {
        'process_name': 'catalina',
        'version_command': 'version',  # Executed via the `catalina.sh` or `catalina.bat` script
        'config_command': '',  # Tomcat configurations are typically edited manually
        'config_files': ['server.xml', 'web.xml']
    }
    # Additional web servers could be added here.
}


# Initial web_servers dictionary is well defined, no changes needed here.

def find_process_path(process_name):
    try:
        # Corrected the command to interpolate process_name and improved the regex.
        ps_output = subprocess.check_output(f"ps -ef | grep [^]]{process_name} | grep -v grep", shell=True, universal_newlines=True)
        match = re.search(r"\S+?/{process_name}", ps_output)
        if match:
            return match.group()
    except subprocess.CalledProcessError:
        pass
    return None

def check_directory_listing_vulnerability(conf_files):
    vulnerable = False
    vulnerabilities = []

    for conf_file in conf_files:
        find_command = f"find / -name {conf_file} -type f 2>/dev/null"
        try:
            find_output = subprocess.check_output(find_command, shell=True, universal_newlines=True).strip().split('\n')
            for file_path in find_output:
                if file_path:
                    with open(file_path, 'r') as file:
                        content = file.read().lower()
                        if "options indexes" in content and "-indexes" not in content:
                            vulnerabilities.append(file_path)
                            vulnerable = True
        except subprocess.CalledProcessError:
            continue

    return vulnerable, vulnerabilities

def main():
    results = {
        "분류": "서비스 관리",
        "코드": "U-35",
        "위험도": "상",
        "진단 항목": "웹서비스 디렉터리 리스팅 제거",
        "진단 결과": None,
        "현황": [],
        "대응방안": "디렉터리 검색 기능 사용하지 않기"
    }

    # Iterating over web_servers to check directory listing vulnerabilities
    for server_name, server_info in web_servers.items():
        vulnerable, vulnerabilities = check_directory_listing_vulnerability(server_info['config_files'])
        if vulnerable:
            results["진단 결과"] = "취약"
            for vulnerability in vulnerabilities:
                results["현황"].append(f"{vulnerability} 파일에 디렉터리 검색 기능을 사용하도록 설정되어 있습니다.")
        else:
            if results["진단 결과"] != "취약":  # If any server is vulnerable, the overall result remains "취약"
                results["진단 결과"] = "양호"
    
    if results["진단 결과"] == "양호":
        results["현황"].append("웹서비스 디렉터리 리스팅이 적절히 제거되었습니다.")

    print(json.dumps(results, ensure_ascii=False, indent=4))

if __name__ == "__main__":
    main()
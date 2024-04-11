#!/usr/bin/python3
import subprocess
import json

# Mapping of web servers to their configuration files and directives for file upload and download restrictions
web_servers = {
    'Apache': {
        'config_files': ['httpd.conf', 'apache2.conf', '.htaccess'],
        'upload_directive': 'LimitRequestBody',  # Apache directive to limit request body size
        'download_directive': ''  # For Apache, download restrictions are typically managed at the application level
    },
    'Nginx': {
        'config_files': ['nginx.conf'],
        'upload_directive': 'client_max_body_size',  # Nginx directive to limit request body size
        'download_directive': ''  # For Nginx, download restrictions are typically managed at the application level
    },
    'LiteSpeed': {
        'config_files': ['httpd_config.conf', '.htaccess'],
        'upload_directive': 'MaxRequestBodySize',  # LiteSpeed supports Apache's LimitRequestBody directive
        'download_directive': ''  # Similar to Apache, LiteSpeed would manage download restrictions at the application level
    },
    'Microsoft-IIS': {
        'config_files': ['web.config'],
        'upload_directive': 'maxAllowedContentLength',  # IIS directive to limit request body size in web.config
        'download_directive': ''  # IIS download restrictions are typically managed at the application level or via ASP.NET settings
    },
    'Node.js': {
        'config_files': [],  # Node.js applications specify these limits in code, not in a server-wide config file
        'upload_directive': 'body-parser limit',  # Example using body-parser middleware for Express.js
        'download_directive': ''  # Node.js does not have a server-wide setting for download limits; this is managed in application code
    },
    'Envoy': {
        'config_files': ['envoy.yaml'],
        'upload_directive': 'max_request_bytes',  # Directive to limit request body size in Envoy configuration
        'download_directive': ''  # Download restrictions are not directly configurable in Envoy
    },
    'Caddy': {
        'config_files': ['Caddyfile'],
        'upload_directive': 'max_request_body',  # Directive in Caddy to limit request body size
        'download_directive': ''  # Download limits in Caddy are not specified through a simple directive
    },
    'Tomcat': {
        'config_files': ['server.xml', 'web.xml'],
        'upload_directive': 'maxPostSize',  # Attribute in Tomcat's <Connector> element to limit request body size
        'download_directive': ''  # Tomcat download restrictions are typically managed at the application level
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

def check_upload_download_restrictions(server_info, found_files):
    vulnerabilities = []

    for file_path in found_files:
        try:
            with open(file_path, 'r') as file:
                content = file.read()
                if (server_info['upload_directive'] and server_info['upload_directive'] not in content) or \
                   (server_info['download_directive'] and server_info['download_directive'] not in content):
                    vulnerabilities.append(file_path)
        except IOError:
            continue

    return vulnerabilities

def main():
    results = {
        "분류": "서비스 관리",
        "코드": "U-40",
        "위험도": "상",
        "진단 항목": "웹서비스 파일 업로드 및 다운로드 제한",
        "진단 결과": None,
        "현황": [],
        "대응방안": "파일 업로드 및 다운로드 제한 설정"
    }

    overall_vulnerable = False

    for server_name, server_info in web_servers.items():
        found_files = find_config_files(server_info['config_files'])
        vulnerabilities = check_upload_download_restrictions(server_info, found_files)
        if vulnerabilities:
            overall_vulnerable = True
            for vulnerability in vulnerabilities:
                results["현황"].append(f"{vulnerability} 파일에서 {server_name}의 파일 업로드 및 다운로드 제한 설정이 부적절합니다.")

    if overall_vulnerable:
        results["진단 결과"] = "취약"
    else:
        results["진단 결과"] = "양호"
        results["현황"].append("모든 검사된 웹서비스 설정 파일에서 파일 업로드 및 다운로드가 적절히 제한되어 있습니다.")

    print(json.dumps(results, ensure_ascii=False, indent=4))

if __name__ == "__main__":
    main()

#!/usr/bin/python3
import subprocess
import json

web_servers = {
    'Apache': {
        'config_files': ['httpd.conf', 'apache2.conf', '.htaccess'],
        'restriction_setting': 'AllowOverride None'
    },
    'Nginx': {
        'config_files': ['nginx.conf'],
        'restriction_setting': 'deny all;'
    },
    'LiteSpeed': {
        'config_files': ['httpd_config.conf', '.htaccess'],
        'restriction_setting': 'AllowOverride None'
    },
    'Microsoft-IIS': {
        'config_files': ['web.config'],
        'restriction_setting': '<authorization><deny users="?" /></authorization>'
    },
    'Node.js': {
        'config_files': [],
        'restriction_setting': 'Use middleware for access control (e.g., helmet, express-jwt)'
    },
    'Envoy': {
        'config_files': ['envoy.yaml'],
        'restriction_setting': 'Apply RBAC policies in configuration to restrict access'
    },
    'Caddy': {
        'config_files': ['Caddyfile'],
        'restriction_setting': 'respond /forbidden/* 403'
    },
    'Tomcat': {
        'config_files': ['web.xml'],
        'restriction_setting': '<security-constraint><web-resource-collection><url-pattern>/restricted/*</url-pattern></web-resource-collection><auth-constraint /></security-constraint>'
    }
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

def check_access_restrictions(server_info, found_files):
    vulnerable = False
    vulnerabilities = []

    for file_path in found_files:
        if file_path:
            with open(file_path, 'r') as file:
                content = file.read()
                if server_info['restriction_setting'] not in content:
                    vulnerable = True
                    vulnerabilities.append(file_path)

    return vulnerable, vulnerabilities

def main():
    results = {
        "분류": "서비스 관리",
        "코드": "U-37",
        "위험도": "상",
        "진단 항목": "웹서비스 상위 디렉토리 접근 금지",
        "진단 결과": None,
        "현황": [],
        "대응방안": "상위 디렉터리에 이동 제한 설정"
    }

    overall_vulnerable = False

    for server_name, server_info in web_servers.items():
        found_files = find_config_files(server_info['config_files'])
        vulnerable, vulnerabilities = check_access_restrictions(server_info, found_files)
        if vulnerable:
            overall_vulnerable = True
            for vulnerability in vulnerabilities:
                results["현황"].append(f"{vulnerability} 파일에서 {server_name} 상위 디렉터리 접근 제한 설정이 부적절합니다.")

    if overall_vulnerable:
        results["진단 결과"] = "취약"
    else:
        results["진단 결과"] = "양호"
        # Corrected to remove the incorrect variable reference and fixed the syntax issue
        results["현황"].append("모든 검사된 파일에서 상위 디렉터리 접근 제한 설정이 적절히 설정되어 있습니다.")

    print(json.dumps(results, ensure_ascii=False, indent=4))

if __name__ == "__main__":
    main()


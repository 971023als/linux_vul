#!/usr/bin/python3
import subprocess
import json

# Mapping of web servers to their configuration files and symbolic link usage restrictions
web_servers = {
    'Apache': {
        'config_files': ['httpd.conf', 'apache2.conf', '.htaccess'],
        'link_restriction_directive': 'Options FollowSymLinks',
        'correct_restriction_setting': 'Options -FollowSymLinks'
    },
    'Nginx': {
        'config_files': ['nginx.conf'],
        'link_restriction_directive': 'disable_symlinks',  # Nginx directive to disable symlinks
        'correct_restriction_setting': 'disable_symlinks if_not_owner from=$document_root;'
    },
    'LiteSpeed': {
        'config_files': ['httpd_config.conf', '.htaccess'],
        'link_restriction_directive': 'Options FollowSymLinks',
        'correct_restriction_setting': 'Options -FollowSymLinks',
        # Note: LiteSpeed is compatible with Apache's .htaccess files for many directives
    },
    'Microsoft-IIS': {
        # IIS manages file access through NTFS permissions, not specific directives in config files
        'config_files': ['web.config'],
        'link_restriction_directive': '',
        'correct_restriction_setting': ''
    },
    'Node.js': {
        # Node.js server behavior is largely defined by the application code rather than server-wide config files
        'config_files': [],
        'link_restriction_directive': '',
        'correct_restriction_setting': ''
    },
    'Envoy': {
        # Envoy configuration does not typically involve direct filesystem access or symlink restrictions
        'config_files': ['envoy.yaml'],
        'link_restriction_directive': '',
        'correct_restriction_setting': ''
    },
    'Caddy': {
        'config_files': ['Caddyfile'],
        # Caddy does not have a direct equivalent for symlink restrictions; behavior is controlled at the filesystem level
        'link_restriction_directive': '',
        'correct_restriction_setting': ''
    },
    'Tomcat': {
        'config_files': ['server.xml', 'web.xml'],
        # Tomcat's handling of symbolic links is set on a per-context basis in the server.xml file
        'link_restriction_directive': 'allowLinking',
        'correct_restriction_setting': 'allowLinking="false"',
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

def check_link_usage_restriction(server_info, found_files):
    vulnerabilities = []

    for file_path in found_files:
        try:
            with open(file_path, 'r') as file:
                for line in file:
                    # Checking both for the directive and ensuring it is set correctly
                    if server_info['link_restriction_directive'] in line and not server_info['correct_restriction_setting'] in line:
                        vulnerabilities.append(file_path)
                        break  # No need to check further once a vulnerability is found
        except IOError:
            continue

    return vulnerabilities

def main():
    results = {
        "분류": "서비스 관리",
        "코드": "U-39",
        "위험도": "상",
        "진단 항목": "웹서비스 링크 사용금지",
        "진단 결과": None,
        "현황": [],
        "대응방안": "심볼릭 링크, aliases 사용 제한"
    }

    overall_vulnerable = False

    for server_name, server_info in web_servers.items():
        found_files = find_config_files(server_info['config_files'])
        vulnerabilities = check_link_usage_restriction(server_info, found_files)
        if vulnerabilities:
            overall_vulnerable = True
            for vulnerability in vulnerabilities:
                results["현황"].append(f"{vulnerability} 파일에서 {server_name} 심볼릭 링크 사용 제한 설정이 부적절합니다.")

    if overall_vulnerable:
        results["진단 결과"] = "취약"
    else:
        results["진단 결과"] = "양호"
        results["현황"].append("모든 검사된 웹서비스 설정 파일에서 심볼릭 링크 사용이 적절히 제한되어 있습니다.")

    print(json.dumps(results, ensure_ascii=False, indent=4))

if __name__ == "__main__":
    main()

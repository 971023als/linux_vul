#!/usr/bin/python3
import subprocess
import json

# Mapping of web servers to their configuration files and directives for document root settings
web_servers = {
    'Apache': {
        'config_files': ['httpd.conf', 'apache2.conf', '.htaccess'],
        'document_root_directive': 'DocumentRoot',
        'default_paths': ['/usr/local/apache/htdocs', '/usr/local/apache2/htdocs', '/var/www/html'],
    },
    'Nginx': {
        'config_files': ['nginx.conf'],
        'document_root_directive': 'root',
        'default_paths': ['/usr/share/nginx/html', '/var/www/html'],
    },
    'LiteSpeed': {
        'config_files': ['httpd_config.conf'],
        'document_root_directive': 'docRoot',
        'default_paths': ['/usr/local/lsws/DEFAULT/html', '/var/www/html'],
    },
    'Microsoft-IIS': {
        # IIS uses a GUI for most configurations but can be managed through applicationHost.config for advanced settings
        'config_files': ['applicationHost.config'],
        'document_root_directive': '',  # Managed through IIS Manager rather than a specific directive
        'default_paths': ['%SystemDrive%\\inetpub\\wwwroot'],  # Default web site path on IIS
    },
    'Node.js': {
        # Node.js does not have a centralized configuration; the document root is set within the application code
        'config_files': [],
        'document_root_directive': '',
        'default_paths': [],  # Varies by application
    },
    'Envoy': {
        'config_files': ['envoy.yaml'],
        'document_root_directive': '',  # Envoy's configuration does not typically define a document root in the same way as a web server
        'default_paths': [],  # N/A
    },
    'Caddy': {
        'config_files': ['Caddyfile'],
        'document_root_directive': 'root',
        'default_paths': ['/var/www/html'],  # Default can vary, commonly set in the Caddyfile
    },
    'Tomcat': {
        'config_files': ['server.xml', 'context.xml'],
        'document_root_directive': 'docBase',  # Used within a <Context> element
        'default_paths': ['/var/lib/tomcat/webapps/ROOT'],  # Default app base in Tomcat
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

def check_document_root_settings(server_info, found_files):
    document_root_set = False
    vulnerable = False

    for file_path in found_files:
        try:
            with open(file_path, 'r') as file:
                for line in file:
                    if server_info['document_root_directive'] in line and not line.strip().startswith('#'):
                        document_root_set = True
                        path = line.split(maxsplit=1)[1].strip('"').strip("'")
                        if path in server_info['default_paths']:
                            vulnerable = True
                            return document_root_set, vulnerable, file_path
        except IOError:
            continue

    return document_root_set, vulnerable, ''

def main():
    results = {
        "분류": "서비스 관리",
        "코드": "U-41",
        "위험도": "상",
        "진단 항목": "웹서비스 영역의 분리",
        "진단 결과": None,
        "현황": [],
        "대응방안": "DocumentRoot 별도 디렉터리 지정"
    }

    overall_document_root_set = False
    overall_vulnerable = False

    for server_name, server_info in web_servers.items():
        found_files = find_config_files(server_info['config_files'])
        document_root_set, vulnerable, file_path = check_document_root_settings(server_info, found_files)
        
        if vulnerable:
            overall_vulnerable = True
            results["현황"].append(f"{server_name}의 DocumentRoot가 기본 디렉터리 {file_path}로 설정되어 있습니다.")
    
    # Adjusted the final assessment logic based on new checks
    if overall_vulnerable:
        results["진단 결과"] = "취약"
    else:
        results["진단 결과"] = "양호"
        results["현황"].append(f"DocumentRoot가 기본 디렉터리 {file_path}로 적절히 설정되어 있습니다.")

    print(json.dumps(results, ensure_ascii=False, indent=4))

if __name__ == "__main__":
    main()

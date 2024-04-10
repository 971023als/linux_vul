#!/usr/bin/python3
import os
import subprocess
import re
import json

web_servers = {
    'Apache': {
        'server_root_directive': 'ServerRoot',
        'unnecessary_files': ['manual', 'cgi-bin/'],
    },
    'Nginx': {
        'server_root_directive': 'root',
        'unnecessary_files': ['html/', 'docs/', 'manual/'],
    },
    'LiteSpeed': {
        'server_root_directive': 'ServerRoot',
        'unnecessary_files': ['_private', '_vti_bin/', 'manual/'],
    },
    'Microsoft-IIS': {
        # IIS does not use a directive in a config file like Apache or Nginx. Configuration is through the IIS Manager and settings in web.config files.
        'unnecessary_files': ['aspnet_client/', '_vti_bin/', 'scripts/'],
    },
    'Node.js': {
        # Node.js applications do not have a server root directive in the same sense; structure is determined by the application's code.
        'unnecessary_files': ['node_modules/', 'test/', 'docs/'],
    },
    'Envoy': {
        # Envoy's configuration does not use a server root directive but defines routes and services in its configuration files.
        'unnecessary_files': ['examples/', 'docs/'],
    },
    'Caddy': {
        'server_root_directive': 'root',
        'unnecessary_files': ['caddy/', 'examples/'],
    },
    'Tomcat': {
        'server_root_directive': 'docBase',
        'unnecessary_files': ['docs/', 'examples/', 'host-manager/', 'manager/'],
    }
    # Additional web servers could be added here.
}


def find_server_roots(server_info):
    server_root_directories = []
    if 'config_files' in server_info:  # Check for 'config_files' key
        for conf_file in server_info['config_files']:
            find_command = f"find / -name {conf_file} -type f 2>/dev/null"
            try:
                find_output = subprocess.check_output(find_command, shell=True, text=True).strip().split('\n')
                for file_path in find_output:
                    if file_path:
                        with open(file_path, 'r') as file:
                            for line in file:
                                if server_info['server_root_directive'] in line and not line.strip().startswith('#'):
                                    serverroot = line.split()[1].strip('"').strip("'")
                                    if serverroot not in server_root_directories:
                                        server_root_directories.append(serverroot)
            except subprocess.CalledProcessError:
                continue
    return server_root_directories


def check_unnecessary_files(server_info, server_root_directories):
    found_files = []
    for directory in server_root_directories:
        for unnecessary_file in server_info['unnecessary_files']:
            full_path = f"{directory}/{unnecessary_file}"
            if subprocess.call(['ls', full_path]) == 0:
                found_files.append(full_path)
    return found_files

def main():
    results = {
        "분류": "서비스 관리",
        "코드": "U-38",
        "위험도": "상",
        "진단 항목": "웹서비스 불필요한 파일 제거",
        "진단 결과": None,
        "현황": [],
        "대응방안": "기본으로 생성되는 불필요한 파일 및 디렉터리 제거"
    }

    overall_found_unnecessary_files = False

    for server_name, server_info in web_servers.items():
        print(f"\nChecking {server_name} for unnecessary web files...")
        if 'config_files' in server_info:  # Only proceed if 'config_files' is present
            server_root_directories = find_server_roots(server_info)
            found_files = check_unnecessary_files(server_info, server_root_directories)
            if found_files:
                overall_found_unnecessary_files = True
                for file in found_files:
                    results["현황"].append(f"Found unnecessary file or directory in {server_name}: {file}")


    if overall_found_unnecessary_files:
        results["진단 결과"] = "취약"
    else:
        results["진단 결과"] = "양호"
        results["현황"].append("No unnecessary web service files or directories found.")

    print(json.dumps(results, ensure_ascii=False, indent=4))

if __name__ == "__main__":
    main()


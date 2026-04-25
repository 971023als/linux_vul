#!/usr/bin/python3
import subprocess
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


# Mapping of web servers to their potential unnecessary files and directories
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
    if 'config_files' not in server_info:
        return server_root_directories  # Return an empty list if no config_files are defined
    
    for conf_file in server_info['config_files']:
        find_command = f"find / -name {conf_file} -type f 2>/dev/null"
        try:
            find_output = subprocess.check_output(find_command, shell=True, universal_newlines=True).strip().split('\n')
            for file_path in find_output:
                if file_path:
                    with open(file_path, 'r') as file:
                        for line in file:
                            if server_info.get('server_root_directive', '') in line and not line.strip().startswith('#'):
                                serverroot = line.split()[1].strip('"').strip("'")
                                if serverroot not in server_root_directories:
                                    server_root_directories.append(serverroot)
        except subprocess.CalledProcessError:
            continue
    return server_root_directories

def check_unnecessary_files(server_info, server_root_directories):
    found_files = []
    for directory in server_root_directories:
        for unnecessary_file in server_info.get('unnecessary_files', []):
            full_path = os.path.join(directory, unnecessary_file)
            if os.path.exists(full_path):
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
        server_root_directories = find_server_roots(server_info)
        found_files = check_unnecessary_files(server_info, server_root_directories)
        if found_files:
            overall_found_unnecessary_files = True
            for file in found_files:
                results["현황"].append(f"{server_name}: {file} 에서 불필요한 파일이나 디렉터리를 찾았습니다.")

    if overall_found_unnecessary_files:
        results["진단 결과"] = "취약"
    else:
        results["진단 결과"] = "양호"
        # Use a general message instead of referencing 'file' and 'server_name'
        results["현황"].append("모든 검사된 서버에서 불필요한 파일이나 디렉터리가 제거된 상태입니다.")

    print_as_md(results)

if __name__ == "__main__":
    main()


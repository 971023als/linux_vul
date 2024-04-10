#!/usr/bin/python3
import subprocess
import os
import json

def check_ftp_root_access_restriction():
    results = {
        "분류": "서비스 관리",
        "코드": "U-64",
        "위험도": "중",
        "진단 항목": "ftpusers 파일 설정(FTP 서비스 root 계정 접근제한)",
        "진단 결과": "",
        "현황": [],
        "대응방안": "FTP 서비스가 활성화된 경우 root 계정 접속을 차단"
    }

    ftpusers_files = [
        "/etc/ftpusers", "/etc/ftpd/ftpusers", "/etc/proftpd.conf",
        "/etc/vsftp/ftpusers", "/etc/vsftp/user_list", "/etc/vsftpd.ftpusers",
        "/etc/vsftpd.user_list"
    ]

    # Check for running FTP services, using universal_newlines for compatibility with Python 3.6
    ftp_running = subprocess.run(['ps', '-ef'], stdout=subprocess.PIPE, universal_newlines=True).stdout
    if 'ftp' not in ftp_running and 'vsftpd' not in ftp_running and 'proftp' not in ftp_running:
        results["현황"].append("FTP 서비스가 비활성화 되어 있습니다.")
        results["진단 결과"] = "양호"
        return results  # No further checks needed if FTP services are not running

    root_access_restricted = False  # Assume root access is not restricted

    # Check ftpusers files for root access restriction
    for ftpusers_file in ftpusers_files:
        if os.path.exists(ftpusers_file):
            with open(ftpusers_file, 'r') as file:
                file_content = file.read()
                # For proftpd.conf, check for 'RootLogin on'
                if 'proftpd.conf' in ftpusers_file and 'RootLogin on' in file_content:
                    results["진단 결과"] = "취약"
                    results["현황"].append(f"{ftpusers_file} 파일에 'RootLogin on' 설정이 있습니다.")
                    return results
                # For other ftpusers files, check for presence of 'root'
                elif 'root' in file_content:
                    root_access_restricted = True  # Found root in at least one config, assuming restriction is in place

    if root_access_restricted:
        results["진단 결과"] = "양호"
        results["현황"].append("FTP 서비스 root 계정 접근이 제한되어 있습니다.")
    else:
        results["진단 결과"] = "취약"
        results["현황"].append("FTP 서비스 root 계정 접근 제한 설정이 충분하지 않습니다.")

    return results


def main():
    ftp_root_access_restriction_check_results = check_ftp_root_access_restriction()
    print(json.dumps(ftp_root_access_restriction_check_results, ensure_ascii=False, indent=4))

if __name__ == "__main__":
    main()

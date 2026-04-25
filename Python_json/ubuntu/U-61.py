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


def check_ftp_service():
    results = {
        "분류": "서비스 관리",
        "코드": "U-61",
        "위험도": "하",
        "진단 항목": "FTP 서비스 확인",
        "진단 결과": "",
        "현황": [],
        "대응방안": "FTP 서비스가 비활성화 되어 있는 경우"
    }

    ftp_ports = []
    ftp_found = False

    # /etc/services에서 FTP 서비스 포트 확인
    try:
        with open('/etc/services', 'r') as file:
            services_content = file.read()
            ftp_ports = re.findall(r'^ftp\s+(\d+)/tcp', services_content, re.MULTILINE)
            if ftp_ports:
                results["현황"].append(f"FTP 포트가 /etc/services에 설정됨: {', '.join(ftp_ports)}")
                ftp_found = True
    except FileNotFoundError:
        results["현황"].append("/etc/services 파일을 찾을 수 없습니다.")

    # 실행 중인 FTP 서비스 확인 (ss 사용)
    ss_output = subprocess.run(['ss', '-tuln'], stdout=subprocess.PIPE, universal_newlines=True).stdout
    if any(port in ss_output for port in ftp_ports):
        results["현황"].append("FTP 서비스가 실행 중입니다.")
        ftp_found = True

     # vsftpd 및 proftpd 설정 파일 확인
    for ftp_conf in ['vsftpd.conf', 'proftpd.conf']:
        find_conf = subprocess.run(['find', '/', '-name', ftp_conf], stdout=subprocess.PIPE, universal_newlines=True).stdout.splitlines()
        if find_conf:
            results["현황"].append(f"{ftp_conf} 파일이 시스템에 존재합니다.")
            ftp_found = True


    # 일반 FTP 서비스 프로세스 확인
    ps_output = subprocess.run(['ps', '-ef'], stdout=subprocess.PIPE, universal_newlines=True).stdout
    if re.search(r'ftpd|vsftpd|proftpd', ps_output, re.IGNORECASE):
        results["현황"].append("FTP 관련 프로세스가 실행 중입니다.")
        ftp_found = True

    # 진단 결과 업데이트
    if ftp_found:
        results["진단 결과"] = "취약"
    else:
        results["진단 결과"] = "양호"
        results["현황"].append("FTP 서비스 관련 항목이 시스템에 존재하지 않습니다.")

    return results

def main():
    ftp_check_results = check_ftp_service()
    print_as_md(ftp_check_results)

if __name__ == "__main__":
    main()

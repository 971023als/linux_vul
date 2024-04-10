#!/usr/bin/python3
import subprocess
import json
import re

def parse_version(version_string):
    """Parse version string to a tuple of integers."""
    return tuple(map(int, re.findall(r'\d+', version_string)))

def check_command_exists(command):
    """Check if a command exists on the system."""
    try:
        subprocess.check_output(["which", command], stderr=subprocess.PIPE, universal_newlines=True)
        return True
    except subprocess.CalledProcessError:
        return False

def get_bind_version_rpm():
    """Get BIND version using rpm."""
    try:
        return subprocess.check_output("rpm -qa | grep '^bind'", shell=True, universal_newlines=True).strip()
    except subprocess.CalledProcessError:
        return ""

def get_bind_version_dpkg():
    """Get BIND version using dpkg."""
    try:
        return subprocess.check_output("dpkg -l | grep '^ii' | grep 'bind9'", shell=True, universal_newlines=True).strip()
    except subprocess.CalledProcessError:
        return ""

def check_dns_security_patch():
    results = {
        "분류": "서비스 관리",
        "코드": "U-33",
        "위험도": "상",
        "진단 항목": "DNS 보안 버전 패치",
        "진단 결과": "양호",  # Default state
        "현황": [],
        "대응방안": "DNS 서비스 주기적 패치 관리"
    }

    minimum_version = "9.18.7"

    if check_command_exists("rpm"):
        bind_version_output = get_bind_version_rpm()
    elif check_command_exists("dpkg"):
        bind_version_output = get_bind_version_dpkg()

    if bind_version_output:
        version_match = re.search(r'bind(?:9)?-(\d+\.\d+\.\d+)', bind_version_output)
        if version_match:
            current_version = version_match.group(1)
            if parse_version(current_version) < parse_version(minimum_version):
                results["진단 결과"] = "취약"
                results["현황"].append(f"BIND 버전이 최신 버전({minimum_version}) 이상이 아닙니다: {current_version}")
            else:
                results["현황"].append(f"BIND 버전이 최신 버전({minimum_version}) 이상입니다: {current_version}")
        else:
            results["진단 결과"] = "양호"
            results["현황"].append("BIND 버전 확인 중 오류 발생 (버전 정보 없음)")
    else:
        results["진단 결과"] = "오류"
        results["현황"].append("BIND가 설치되어 있지 않거나 rpm/dpkg 명령어 실행 실패")

    return results

def main():
    results = check_dns_security_patch()
    print(json.dumps(results, ensure_ascii=False, indent=4))

if __name__ == "__main__":
    main()

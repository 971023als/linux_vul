#!/usr/bin/python3
import json
import subprocess
import re

def parse_version(version_string):
    """Parse version string to a tuple of integers."""
    return tuple(map(int, re.findall(r'\d+', version_string)))

def check_command_exists(command):
    """Check if a command exists on the system."""
    try:
        subprocess.check_output(["which", command], stderr=subprocess.STDOUT)
        return True
    except subprocess.CalledProcessError:
        return False

def get_bind_version_rpm():
    """Retrieve BIND version on RPM-based systems."""
    if not check_command_exists("rpm"):
        return "rpm_not_found"
    try:
        output = subprocess.check_output(["rpm", "-q", "bind"], stderr=subprocess.STDOUT, text=True).strip()
        return output
    except subprocess.CalledProcessError as e:
        return "bind_not_installed"

def get_bind_version_dpkg():
    """Retrieve BIND version on Debian-based systems."""
    if not check_command_exists("dpkg"):
        return "dpkg_not_found"
    try:
        output = subprocess.check_output(["dpkg", "-l", "bind9"], stderr=subprocess.STDOUT, text=True).strip()
        return output
    except subprocess.CalledProcessError as e:
        return "bind_not_installed"

def check_dns_security_patch():
    results = {
        "분류": "서비스 관리",
        "코드": "U-33",
        "위험도": "상",
        "진단 항목": "DNS 보안 버전 패치",
        "진단 결과": None,
        "현황": [],
        "대응방안": "DNS 서비스 주기적 패치 관리"
    }

    minimum_version = "9.18.7"
    bind_version_output = ""
    if check_command_exists("rpm"):
        bind_version_output = get_bind_version_rpm()
    elif check_command_exists("dpkg"):
        bind_version_output = get_bind_version_dpkg()

    if bind_version_output in ["rpm_not_found", "dpkg_not_found"]:
        results["진단 결과"] = "오류"
        results["현황"].append(f"{bind_version_output} 명령어를 찾을 수 없습니다.")
    elif bind_version_output == "bind_not_installed":
        results["진단 결과"] = "오류"
        results["현황"].append("BIND가 설치되어 있지 않습니다.")
    elif bind_version_output:
        version_match = re.search(r'bind(?:9)?-(\d+\.\d+\.\d+)', bind_version_output)
        if version_match:
            current_version = version_match.group(1)
            if parse_version(current_version) < parse_version(minimum_version):
                results["진단 결과"] = "취약"
                results["현황"].append(f"BIND 버전이 최신 버전({minimum_version}) 이상이 아닙니다: {current_version}")
            else:
                results["진단 결과"] = "양호"
                results["현황"].append(f"BIND 버전이 최신 버전({minimum_version}) 이상입니다: {current_version}")
        else:
            results["진단 결과"] = "오류"
            results["현황"].append("BIND 버전 정보를 파싱할 수 없습니다.")
    else:
        results["진단 결과"] = "오류"
        results["현황"].append("알 수 없는 오류 발생")

    return results

def main():
    results = check_dns_security_patch()
    print(json.dumps(results, ensure_ascii=False, indent=4))

if __name__ == "__main__":
    main()

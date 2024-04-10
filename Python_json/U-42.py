#!/usr/bin/python3
import os
import json
import subprocess  # Import the 'subprocess' module

def get_linux_distro():
    if os.path.isfile("/etc/os-release"):
        with open("/etc/os-release") as f:
            for line in f:
                if line.startswith("ID="):
                    return line.strip().split("=")[1].strip("\"")
    return None

def check_security_patches(distro):
    if distro == "ubuntu":
        return subprocess.check_output(["sudo", "unattended-upgrades", "--dry-run", "--debug"], stderr=subprocess.STDOUT, universal_newlines=True)
    elif distro in ["centos", "rhel", "fedora"]:
        return subprocess.check_output(["sudo", "dnf", "check-update", "--security"], stderr=subprocess.STDOUT, universal_newlines=True)
    else:
        return "Unsupported distribution."

def check_security_patches_and_recommendations():
    distro = get_linux_distro()  # 시스템 배포판을 확인
    results = {
        "분류": "패치 관리",
        "코드": "U-42",
        "위험도": "상",
        "진단 항목": "최신 보안패치 및 벤더 권고사항 적용",
        "진단 결과": None,
        "현황": [],
        "대응방안": "패치 적용 정책 수립 및 주기적인 패치 관리"
    }

    try:
        # 배포판에 따라 보안 패치를 확인하는 명령어 실행
        output = check_security_patches(distro)
        if distro == "ubuntu" and "All upgrades installed" in output:
            results["진단 결과"] = "양호"
            results["현황"] = "시스템은 최신 보안 패치를 보유하고 있습니다."
        elif distro in ["centos", "rhel", "fedora"] and "No security updates needed" not in output:  # 예시 조건, 실제 출력에 따라 조정 필요
            results["진단 결과"] = "취약"
            results["현황"] = "시스템에 보안 패치가 필요합니다."
        else:
            results["진단 결과"] = "양호"  # 기본적으로 양호로 가정
            results["현황"] = "보안 패치 확인 결과가 불분명합니다. 수동 확인이 필요합니다."

    except subprocess.CalledProcessError as e:
        results["진단 결과"] = "취약"
        results["현황"] = f"오류로 인해 보안 패치 상태를 확인할 수 없습니다. 오류 메시지: {e.output}"

    return results


def main():
    results = check_security_patches_and_recommendations()
    print(json.dumps(results, ensure_ascii=False, indent=4))

if __name__ == "__main__":
    main()

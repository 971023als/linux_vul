#!/usr/bin/python3
import os
import json
import subprocess
import re  # re 모듈을 임포트합니다.

def get_linux_distro():
    if os.path.isfile("/etc/os-release"):
        with open("/etc/os-release") as f:
            for line in f:
                if line.startswith("ID="):
                    return line.strip().split("=")[1].strip("\"")
    return None

def check_security_patches(distro):
    if distro == "ubuntu":
        command = ["apt", "list", "--upgradable"]
    elif distro in ["centos", "rhel", "fedora"]:
        command = ["dnf", "list", "sec"]
    else:
        return "Unsupported distribution."
    
    try:
        output = subprocess.check_output(command, stderr=subprocess.STDOUT, text=True)
        return output
    except subprocess.CalledProcessError as e:
        return f"Command failed: {e.output}"

def check_security_patches_and_recommendations():
    distro = get_linux_distro()
    results = {
        "분류": "패치 관리",
        "코드": "U-42",
        "위험도": "상",
        "진단 항목": "최신 보안패치 및 벤더 권고사항 적용",
        "진단 결과": None,
        "현황": [],
        "대응방안": "패치 적용 정책 수립 및 주기적인 패치 관리"
    }

    output = check_security_patches(distro)
    if "Command failed" in output:
        results["진단 결과"] = "오류"
        results["현황"].append(output)
    elif "Unsupported distribution." in output:
        results["진단 결과"] = "오류"
        results["현황"].append(output)
    else:
        if distro == "ubuntu":
            upgradable = re.findall(r'^\S+', output, re.MULTILINE)
            if upgradable:
                results["진단 결과"] = "취약"
                results["현황"].append("업그레이드 가능한 패키지: " + ", ".join(upgradable))
            else:
                results["진단 결과"] = "양호"
                results["현황"].append("모든 패키지가 최신 상태입니다.")
        elif distro in ["centos", "rhel", "fedora"]:
            if "No security updates needed" not in output:
                results["진단 결과"] = "취약"
                security_updates = re.findall(r'^\S+', output, re.MULTILINE)
                results["현황"].append("필요한 보안 패치: " + ", ".join(security_updates))
            else:
                results["진단 결과"] = "양호"
                results["현황"].append("필요한 보안 패치가 없습니다.")

    return results

def main():
    results = check_security_patches_and_recommendations()
    print(json.dumps(results, ensure_ascii=False, indent=4))

if __name__ == "__main__":
    main()

#!/usr/bin/python3
import json
import subprocess
import platform  # 시스템 정보를 가져오기 위한 모듈

def get_linux_distribution():
    try:
        with open("/etc/os-release") as f:
            os_release_info = {}
            for line in f:
                key, value = line.strip().split("=", 1)
                os_release_info[key] = value.strip('"')
            return os_release_info.get("NAME", "").lower(), os_release_info.get("VERSION_ID", "")
    except FileNotFoundError:
        return "unknown", "unknown"

def check_security_patches_and_recommendations():
    results = {
        "분류": "패치 관리",
        "코드": "U-42",
        "위험도": "상",
        "진단 항목": "최신 보안패치 및 벤더 권고사항 적용",
        "진단 결과": None,
        "현황": [],
        "대응방안": "패치 적용 정책 수립 및 주기적인 패치 관리"
    }

    dist_name, _ = get_linux_distribution()
    if 'ubuntu' in dist_name:
        try:
            output = subprocess.check_output(["sudo", "unattended-upgrades", "--dry-run", "--debug"], stderr=subprocess.STDOUT, universal_newlines=True)
            if "All upgrades installed" in output:
                results["진단 결과"] = "양호"
                results["현황"] = "시스템은 최신 보안 패치를 보유하고 있습니다."
            else:
                results["진단 결과"] = "취약"
                results["현황"] = "시스템에 보안 패치가 필요합니다."
        except subprocess.CalledProcessError as e:
            if "command not found" in e.output:
                results["진단 결과"] = "오류"
                results["현황"] = "unattended-upgrades 명령어를 찾을 수 없습니다. 'sudo apt-get install unattended-upgrades'를 실행하여 설치해 주세요."
            else:
                results["진단 결과"] = "취약"
                results["현황"] = "오류로 인해 보안 패치 상태를 확인할 수 없습니다."
    else:
        results["진단 결과"] = "오류"
        results["현황"] = f"{dist_name}은(는) 이 스크립트에서 지원하지 않는 배포판입니다. 해당 배포판의 보안 패치 확인 방법을 참고해 주세요."

    return results

def main():
    results = check_security_patches_and_recommendations()
    print(json.dumps(results, ensure_ascii=False, indent=4))

if __name__ == "__main__":
    main()

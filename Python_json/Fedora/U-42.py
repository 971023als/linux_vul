#!/usr/bin/python3
import json
import subprocess  # Import the 'subprocess' module

def check_security_patches_and_recommendations():
    results = {
        "분류": "패치 관리",
        "코드": "U-42",
        "위험도": "상",
        "진단 항목": "최신 보안패치 및 벤더 권고사항 적용",
        "진단 결과": None,  # 초기 상태 설정, 검사 후 결과에 따라 업데이트
        "현황": [],
        "대응방안": "패치 적용 정책 수립 및 주기적인 패치 관리"
    }

    try:
        # Ubuntu 시스템에서 보안 패치를 확인하는 명령어입니다.
        output = subprocess.check_output(["sudo", "unattended-upgrades", "--dry-run", "--debug"], stderr=subprocess.STDOUT, universal_newlines=True)
        
        # 출력 내용에서 보안 패치 여부를 확인합니다.
        if "All upgrades installed" in output:
            results["진단 결과"] = "양호"
            results["현황"] = "시스템은 최신 보안 패치를 보유하고 있습니다."
        else:
            results["진단 결과"] = "취약"
            results["현황"] = "시스템에 보안 패치가 필요합니다."

    except subprocess.CalledProcessError as e:
        results["진단 결과"] = "취약"
        results["현황"] = "오류로 인해 보안 패치 상태를 확인할 수 없습니다."

    return results

def main():
    results = check_security_patches_and_recommendations()
    print(json.dumps(results, ensure_ascii=False, indent=4))

if __name__ == "__main__":
    main()

#!/usr/bin/python3
import subprocess
import os
import re
import json

def check_automountd_disabled():
    results = {
        "분류": "서비스 관리",
        "코드": "U-26",
        "위험도": "상",
        "진단 항목": "automountd 제거",
        "진단 결과": None,  # 초기 상태 설정, 검사 후 결과에 따라 업데이트
        "현황": [],
        "대응방안": "automountd 서비스 비활성화"
    }

def check_service_running(service_name):
    try:
        # systemctl 명령을 사용하여 서비스의 상태를 확인
        result = subprocess.run(["systemctl", "is-active", service_name], stdout=subprocess.PIPE, stderr=subprocess.PIPE, universal_newlines=True)
        return result.stdout.strip() == "active"
    except Exception as e:
        # 오류가 발생하면 False를 반환
        print(f"오류 발생: {e}")
        return False

def main():
    results = {"진단 결과": "", "현황": []}
    try:
        if check_service_running("automountd") or check_service_running("autofs"):
            results["진단 결과"] = "취약"
            results["현황"].append("automountd 서비스가 실행 중입니다.")
        else:
            results["진단 결과"] = "양호"
            results["현황"].append("automountd 서비스가 비활성화되어 있습니다.")
    except Exception as e:
        results["진단 결과"] = "오류"
        results["현황"].append(f"automountd 서비스 확인 중 오류 발생: {str(e)}")

    return results

if __name__ == "__main__":
    print(main())

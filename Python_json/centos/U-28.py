#!/usr/bin/python3
import subprocess
import json

def check_nis_services_status():
    results = {
        "분류": "서비스 관리",
        "코드": "U-28",
        "위험도": "상",
        "진단 항목": "NIS, NIS+ 점검",
        "진단 결과": None,  # 초기 상태 설정, 검사 후 결과에 따라 업데이트
        "현황": [],
        "대응방안": "NIS 서비스 비활성화 혹은 필요 시 NIS+ 사용"
    }

    cmd = "ps -ef | grep '[y]pserv\|[y]pbind\|[y]pxfrd\|[r]pc.yppasswdd\|[r]pc.ypupdated'"
    process = subprocess.run(cmd, shell=True, text=True, capture_output=True)

    if process.returncode == 0:
        # NIS 관련 프로세스가 실행 중임
        results["진단 결과"] = "취약"
        results["현황"].append("NIS 서비스가 실행 중입니다.")
    elif process.returncode == 1:
        # NIS 관련 프로세스가 실행 중이지 않음
        results["진단 결과"] = "양호"
        results["현황"].append("NIS 서비스가 비활성화되어 있습니다.")
    else:
        # 명령어 실행 중 오류 발생
        results["진단 결과"] = "오류"
        results["현황"].append(f"NIS 서비스 확인 중 오류 발생: {process.stderr}")

    return results

def main():
    results = check_nis_services_status()
    print(json.dumps(results, ensure_ascii=False, indent=4))

if __name__ == "__main__":
    main()

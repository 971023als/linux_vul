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

def check_nis_processes():
    nis_processes = ['ypserv', 'ypbind', 'ypxfrd', 'rpc.yppasswdd', 'rpc.ypupdated']
    try:
        # ps 명령을 사용하여 실행 중인 프로세스를 확인
        result = subprocess.Popen(["ps", "-e"], stdout=subprocess.PIPE, stderr=subprocess.PIPE, universal_newlines=True)
        output, _ = result.communicate()
        output_lines = output.split('\n')
        for line in output_lines:
            if any(nis_process in line.lower() for nis_process in nis_processes):
                return True
        return False
    except Exception as e:
        print(f"오류 발생: {e}")
        return False

def main():
    results = {"진단 결과": "", "현황": []}
    try:
        if check_nis_processes():
            results["진단 결과"] = "취약"
            results["현황"].append("NIS 서비스가 실행 중입니다.")
        else:
            results["진단 결과"] = "양호"
            results["현황"].append("NIS 서비스가 비활성화되어 있습니다.")
    except Exception as e:
        results["진단 결과"] = "오류"
        results["현황"].append(f"NIS 서비스 확인 중 오류 발생: {str(e)}")

    return results

if __name__ == "__main__":
    print(main())

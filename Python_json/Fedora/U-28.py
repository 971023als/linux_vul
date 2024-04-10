#!/usr/bin/python3
import subprocess
import json

def check_nis_processes():
    nis_processes = ['ypserv', 'ypbind', 'ypxfrd', 'rpc.yppasswdd', 'rpc.ypupdated']
    try:
        # 실행 중인 모든 프로세스를 확인
        result = subprocess.Popen(["ps", "-e"], stdout=subprocess.PIPE, stderr=subprocess.PIPE, universal_newlines=True)
        output, _ = result.communicate()
        for process in nis_processes:
            if process in output.lower():
                return True
        return False
    except Exception as e:
        print(f"오류 발생: {e}")
        return False

def main():
    results = {
        "분류": "서비스 관리",
        "코드": "U-28",
        "위험도": "상",
        "진단 항목": "NIS, NIS+ 점검",
        "진단 결과": None,
        "현황": [],
        "대응방안": "NIS 서비스 비활성화 혹은 필요 시 NIS+ 사용"
    }

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

    print(results)

if __name__ == "__main__":
    main()

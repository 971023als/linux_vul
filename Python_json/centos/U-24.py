#!/usr/bin/python3
import subprocess
import json
import sys

def check_nfs_services_disabled():
    results = {
        "분류": "서비스 관리",
        "코드": "U-24",
        "위험도": "상",
        "진단 항목": "NFS 서비스 비활성화",
        "진단 결과": None,
        "현황": [],
        "대응방안": "불필요한 NFS 서비스 관련 데몬 비활성화"
    }

    try:
        # NFS 서비스에 대한 프로세스를 확인
        nfs_processes = ["nfs", "rpc.statd", "statd", "rpc.lockd", "lockd"]
        for process_name in nfs_processes:
            process_check = subprocess.run(['pgrep', process_name], capture_output=True, text=True)
            if process_check.returncode == 0:
                results["진단 결과"] = "취약"
                results["현황"].append(f"불필요한 NFS 서비스 관련 데몬({process_name})이 실행 중입니다.")

        if results["진단 결과"] is None:
            results["진단 결과"] = "양호"
            results["현황"].append("NFS 서비스 관련 데몬이 비활성화되어 있습니다.")
    except Exception as e:
        results["진단 결과"] = "오류"
        results["현황"].append(f"서비스 확인 중 오류 발생: {str(e)}")

    return results

if __name__ == "__main__":
    print(check_nfs_services_disabled())

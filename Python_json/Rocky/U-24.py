#!/usr/bin/python3
import subprocess
import json

def check_nfs_services_disabled():
    results = {
        "분류": "서비스 관리",
        "코드": "U-24",
        "위험도": "상",
        "진단 항목": "NFS 서비스 비활성화",
        "진단 결과": None,  # Initial state
        "현황": [],
        "대응방안": "불필요한 NFS 서비스 관련 데몬 비활성화"
    }

    nfs_processes = ["nfs", "rpc.statd", "statd", "rpc.lockd", "lockd"]
    active_daemons = []

    try:
        for process_name in nfs_processes:
            process_check = subprocess.run(['pgrep', '-f', process_name], stdout=subprocess.PIPE, stderr=subprocess.PIPE, universal_newlines=True)
            if process_check.returncode == 0:
                active_daemons.append(process_name)
        
        if active_daemons:
            results["진단 결과"] = "취약"
            results["현황"].append(f"불필요한 NFS 서비스 관련 데몬({', '.join(active_daemons)})이 실행 중입니다.")
        else:
            results["진단 결과"] = "양호"
            results["현황"].append("NFS 서비스 관련 데몬이 비활성화되어 있습니다.")
    except Exception as e:
        results["진단 결과"] = "오류"
        results["현황"].append(f"서비스 확인 중 오류 발생: {str(e)}")

    return results

if __name__ == "__main__":
    print(check_nfs_services_disabled())

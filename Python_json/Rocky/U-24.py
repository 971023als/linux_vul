#!/usr/bin/python3
import subprocess
import json
import sys
import psutil

def check_nfs_services_disabled():
    results = {
        "분류": "서비스 관리",
        "코드": "U-24",
        "위험도": "상",
        "진단 항목": "NFS 서비스 비활성화",
        "진단 결과": None,  # 초기 상태 설정, 검사 후 결과에 따라 업데이트
        "현황": [],
        "대응방안": "불필요한 NFS 서비스 관련 데몬 비활성화"
    }

def check_nfs_processes():
    nfs_processes = ["nfs", "rpc.statd", "statd", "rpc.lockd", "lockd"]
    processes = psutil.process_iter()

    nfs_process_running = False
    for process in processes:
        for name in nfs_processes:
            if name in process.name().lower():
                nfs_process_running = True
                break

    return nfs_process_running

def main():
    results = {"진단 결과": "", "현황": []}
    try:
        if check_nfs_processes():
            results["진단 결과"] = "취약"
            results["현황"].append("불필요한 NFS 서비스 관련 데몬이 실행 중입니다.")
        else:
            results["진단 결과"] = "양호"
            results["현황"].append("NFS 서비스 관련 데몬이 비활성화되어 있습니다.")
    except Exception as e:
        results["진단 결과"] = "오류"
        results["현황"].append(f"서비스 확인 중 오류 발생: {str(e)}")

    return results

if __name__ == "__main__":
    print(main())

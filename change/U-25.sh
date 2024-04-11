#!/usr/bin/python3
import subprocess
import json
import os

def check_nfs_access_control():
    results = {
        "분류": "서비스 관리",
        "코드": "U-25",
        "위험도": "상",
        "진단 항목": "NFS 접근 통제",
        "진단 결과": None,  # 초기 상태 설정, 검사 후 결과에 따라 업데이트
        "현황": [],
        "대응방안": "불필요한 NFS 서비스를 사용하지 않거나, 사용 시 everyone 공유 제한"
    }

    cmd = "ps -ef | grep -iE 'nfs|rpc.statd|statd|rpc.lockd|lockd' | grep -ivE 'grep|kblockd|rstatd|'"
    process = subprocess.run(cmd, shell=True, text=True, capture_output=True)

    if process.returncode == 0:
        # NFS 서비스 실행 상태 확인 성공
        if os.path.isfile("/etc/exports"):
            with open("/etc/exports", "r") as file:
                exports_content = file.readlines()
            
            exports_content = [line for line in exports_content if line.strip() and not line.startswith("#")]
            all_exports = any("*" in line for line in exports_content)
            insecure_exports = any("insecure" in line for line in exports_content)
            squash_not_set = all("root_squash" not in line and "all_squash" not in line for line in exports_content)

            if all_exports or insecure_exports or squash_not_set:
                results["진단 결과"] = "취약"
                if all_exports:
                    results["현황"].append("/etc/exports 파일에 '*' 설정이 있습니다.")
                if insecure_exports:
                    results["현황"].append("/etc/exports 파일에 'insecure' 옵션이 설정되어 있습니다.")
                if squash_not_set:
                    results["현황"].append("/etc/exports 파일에 'root_squash' 또는 'all_squash' 옵션이 설정되어 있지 않습니다.")
        else:
            results["진단 결과"] = "취약"
            results["현황"].append("NFS 서비스가 실행 중이지만, /etc/exports 파일이 존재하지 않습니다.")
    elif process.returncode == 1:
        results["진단 결과"] = "양호"
        results["현황"].append("NFS 서비스가 실행 중이지 않습니다.")
    else:
        results["진단 결과"] = "오류"
        results["현황"].append(f"NFS 서비스 확인 중 오류 발생: {process.stderr}")

    # 진단 결과가 명시적으로 설정되지 않은 경우 기본값을 "양호"로 설정
    if results["진단 결과"] is None:
        results["진단 결과"] = "양호"
        results["현황"].append("NFS 접근 통제 설정에 문제가 없습니다.")

    return results

def main():
    results = check_nfs_access_control()
    print(json.dumps(results, ensure_ascii=False, indent=4))

if __name__ == "__main__":
    main()

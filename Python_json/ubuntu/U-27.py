#!/usr/bin/python3
import os
import re
import json

def check_rpc_services_disabled():
    results = {
        "분류": "서비스 관리",
        "코드": "U-27",
        "위험도": "상",
        "진단 항목": "RPC 서비스 확인",
        "진단 결과": None,  # 초기 상태 설정, 검사 후 결과에 따라 업데이트
        "현황": [],
        "대응방안": "불필요한 RPC 서비스 비활성화"
    }

    rpc_services = ["rpc.cmsd", "rpc.ttdbserverd", "sadmind", "rusersd", "walld", "sprayd", "rstatd", "rpc.nisd", "rexd", "rpc.pcnfsd", "rpc.statd", "rpc.ypupdated", "rpc.rquotad", "kcms_server", "cachefsd"]
    xinetd_dir = "/etc/xinetd.d"
    inetd_conf = "/etc/inetd.conf"
    service_found = False

    # /etc/xinetd.d 아래 서비스 검사
    if os.path.isdir(xinetd_dir):
        for service in rpc_services:
            service_path = os.path.join(xinetd_dir, service)
            if os.path.isfile(service_path):
                with open(service_path, 'r') as file:
                    if 'disable = yes' not in file.read():
                        results["진단 결과"] = "취약"
                        results["현황"].append(f"불필요한 RPC 서비스가 /etc/xinetd.d 디렉터리 내 서비스 파일에서 실행 중입니다: {service}")
                        service_found = True

    # /etc/inetd.conf 파일 내 서비스 검사
    if os.path.isfile(inetd_conf):
        with open(inetd_conf, 'r') as file:
            inetd_contents = file.read()
            for service in rpc_services:
                if service in inetd_contents:
                    results["진단 결과"] = "취약"
                    results["현황"].append(f"불필요한 RPC 서비스가 /etc/inetd.conf 파일에서 실행 중입니다: {service}")
                    service_found = True

    if not service_found:
        results["진단 결과"] = "양호"
        results["현황"].append("모든 불필요한 RPC 서비스가 비활성화되어 있습니다.")

    return results

def main():
    results = check_rpc_services_disabled()
    print(json.dumps(results, ensure_ascii=False, indent=4))

if __name__ == "__main__":
    main()

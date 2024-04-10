#!/usr/bin/python3
import os
import stat
import pwd
import json

def check_at_service_permissions():
    results = {
        "분류": "서비스 관리",
        "코드": "U-65",
        "위험도": "중",
        "진단 항목": "at 서비스 권한 설정",
        "진단 결과": "",  # 초기 값 설정하지 않음
        "현황": [],
        "대응방안": "일반 사용자의 at 명령어 사용 금지 및 관련 파일 권한 640 이하 설정"
    }

    # Initialize a flag to track permission issues
    permission_issues_found = False

    # Check for at command path in PATH variable
    at_command_paths = []
    for path in os.environ["PATH"].split(os.pathsep):
        at_path = os.path.join(path, "at")
        if os.path.isfile(at_path):
            at_command_paths.append(at_path)

    # Check permissions for at command if exists
    for at_path in at_command_paths:
        try:
            st = os.stat(at_path)
            permissions = stat.S_IMODE(st.st_mode)
            if permissions & stat.S_IXOTH or permissions & stat.S_IWOTH or permissions & stat.S_IROTH:
                results["진단 결과"] = "취약"
                permission_issues_found = True
                results["현황"].append(f"{at_path} 실행 파일이 다른 사용자(other)에 의해 실행이 가능합니다.")
        except FileNotFoundError:
            pass  # If the file doesn't exist, skip it

    # Check /etc/at.allow and /etc/at.deny files
    at_access_control_files = ["/etc/at.allow", "/etc/at.deny"]
    for file in at_access_control_files:
        if os.path.isfile(file):
            st = os.stat(file)
            permissions = stat.S_IMODE(st.st_mode)
            file_owner = pwd.getpwuid(st.st_uid).pw_name
            if file_owner != "root" or permissions > 0o640:
                results["진단 결과"] = "취약"
                permission_issues_found = True
                permission_str = oct(permissions)[-3:]
                results["현황"].append(f"{file} 파일의 소유자가 {file_owner}이고, 권한이 {permission_str}입니다.")

    # Finalize the diagnosis result based on the checks
    if not permission_issues_found:
        results["진단 결과"] = "양호"
        results["현황"].append("모든 at 관련 파일이 적절한 권한 설정을 가지고 있습니다.")

    return results

def main():
    at_service_permission_check_results = check_at_service_permissions()
    print(json.dumps(at_service_permission_check_results, ensure_ascii=False, indent=4))

if __name__ == "__main__":
    main()

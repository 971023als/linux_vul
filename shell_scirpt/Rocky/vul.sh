#!/bin/bash

# 초기 설정
declare -A OS_PACKAGE_MANAGER=(
    [debian]="apt-get"
    [ubuntu]="apt-get"
    [centos]="yum"
    [rhel]="yum"
    [fedora]="dnf"
)

declare -A OS_PACKAGES=(
    [debian]="apache2 libapache2-mod-wsgi-py3 python3-venv"
    [ubuntu]="apache2 libapache2-mod-wsgi-py3 python3-venv"
    [centos]="httpd mod_wsgi python3"
    [rhel]="httpd mod_wsgi python3"
    [fedora]="httpd mod_wsgi python3-virtualenv" # 여기를 수정했습니다
)

CRON_JOB="/usr/bin/python3 /root/linux_vuln/Python_json/centos/vul.sh"
NOW=$(date +'%Y-%m-%d_%H-%M-%S')
WEB_DIRECTORY="/var/www/html"
RESULTS_PATH="$WEB_DIRECTORY/results_${NOW}.json"
ERRORS_PATH="$WEB_DIRECTORY/errors_${NOW}.log"
CSV_PATH="$WEB_DIRECTORY/results_${NOW}.csv"
HTML_PATH="$WEB_DIRECTORY/index.html"

# 운영체제 확인 및 패키지 관리자 설정
setup_environment() {
    if [ ! -f /etc/os-release ]; then
        echo "/etc/os-release 파일을 찾을 수 없습니다. 리눅스 배포판을 확인할 수 없습니다."
        exit 1
    fi

    source /etc/os-release
    PKG_MANAGER=${OS_PACKAGE_MANAGER[$ID]}
    PACKAGES=${OS_PACKAGES[$ID]}
    if [ -z "$PKG_MANAGER" ] || [ -z "$PACKAGES" ]; then
        echo "지원되지 않는 리눅스 배포판입니다."
        exit 1
    fi

    [ "$ID" == "centos" ] || [ "$ID" == "rhel" ] && [ "${VERSION_ID%%.*}" -ge 8 ] && PKG_MANAGER="dnf"

    install_packages
}

# 필요 패키지 설치 전 sudo 권한 확인
check_sudo() {
    if ! sudo -v; then
        echo "이 스크립트를 실행하기 위해서는 sudo 권한이 필요합니다."
        exit 1
    fi
}

install_packages() {
    check_sudo
    echo "필요한 패키지를 설치합니다: $PACKAGES"
    sudo $PKG_MANAGER update -y
    for PACKAGE in $PACKAGES; do
        sudo $PKG_MANAGER install $PACKAGE -y || { echo "$PACKAGE 패키지 설치 실패"; exit 1; }
    done
    setup_cron_job
}

# Cron 작업 설정 및 cronie 패키지 설치
setup_cron_job() {
    # crontab 명령이 존재하는지 확인
    if ! command -v crontab &> /dev/null; then
        echo "crontab 명령을 찾을 수 없습니다. cronie 패키지를 설치합니다."
        sudo $PKG_MANAGER install cronie -y
        sudo systemctl enable crond.service
        sudo systemctl start crond.service
    fi

    # Cron 작업 추가
    (crontab -l 2>/dev/null | grep -Fq "$CRON_JOB") && echo "Cron job이 이미 존재합니다." || {
        (crontab -l 2>/dev/null; echo "0 0 * * * $CRON_JOB # 매일 스크립트 실행") | crontab - &&
        echo "Cron job을 추가했습니다." || {
            echo "Cron job 추가에 실패했습니다. crontab이 설정되어 있는지 확인해주세요."
            exit 1
        }
    }
}



# Apache 인코딩 설정
setup_apache_encoding() {
    echo "Apache 인코딩 설정 시작..."
    local apache_config
    
    # 운영체제별 Apache 설정 파일 경로 지정
    echo "현재 운영 체제: $ID"
    if [[ "$ID" == "debian" ]] || [[ "$ID" == "ubuntu" ]]; then
        apache_config="/etc/apache2/apache2.conf"
        echo "Debian/Ubuntu 시스템 감지됨. Apache 설정 파일: $apache_config"
    elif [[ "$ID" == "centos" ]] || [[ "$ID" == "rhel" ]] || [[ "$ID" == "fedora" ]]; then
        apache_config="/etc/httpd/conf/httpd.conf"
        echo "CentOS/RHEL/Fedora 시스템 감지됨. Apache 설정 파일: $apache_config"
    else
        echo "지원되지 않는 리눅스 배포판입니다. Apache 설정 파일 경로를 수동으로 지정해야 합니다."
        return 1
    fi

    # UTF-8 설정 추가
    echo "Apache 설정 파일에 UTF-8 charset 설정을 검사합니다."
    if grep -q "AddDefaultCharset UTF-8" "$apache_config"; then
        echo "UTF-8 charset 설정이 이미 존재합니다. 추가 작업 없음."
    else
        echo "Apache 설정 파일에 UTF-8 charset 설정이 존재하지 않습니다. 설정을 추가합니다."
        if echo "AddDefaultCharset UTF-8" | sudo tee -a "$apache_config" > /dev/null; then
            echo "Apache 설정 파일에 UTF-8 charset 설정을 성공적으로 추가했습니다."
        else
            echo "Apache 설정 파일 수정 중 오류가 발생했습니다. 관리자 권한이 있는지 확인해주세요."
            return 1
        fi
    fi

    echo "Apache 인코딩 설정 완료."
}


# 보안 점검 스크립트 실행 및 결과 처리
execute_security_checks() {
    echo "[" > "$RESULTS_PATH"
    declare -a errors
    first_entry=true

    for i in $(seq -f "%02g" 1 72); do
        SCRIPT_PATH="U-$i.sh"
        if [ -f "$SCRIPT_PATH" ]; then
            RESULT=$(python3 "$SCRIPT_PATH" 2>>"$ERRORS_PATH")
            if [ $? -eq 0 ]; then
                [ "$first_entry" = false ] && echo "," >> "$RESULTS_PATH"
                first_entry=false
                echo "$RESULT" >> "$RESULTS_PATH"
            else
                errors+=("Error running $SCRIPT_PATH")
            fi
        else
            errors+=("$SCRIPT_PATH not found")
        fi
    done
    echo "]" >> "$RESULTS_PATH"

    if [ ${#errors[@]} -gt 0 ]; then
        printf "%s\n" "${errors[@]}" >> "$ERRORS_PATH"
        echo "에러가 존재함 -> $ERRORS_PATH"
    else
        echo "에러 없음."
    fi
}

convert_results() {
    python3 -c "
import json
import csv
from pathlib import Path

json_path = Path('$RESULTS_PATH')
csv_path = Path('$CSV_PATH')
html_path = Path('$HTML_PATH')

def json_to_csv():
    with json_path.open('r', encoding='utf-8') as json_file, csv_path.open('w', newline='', encoding='utf-8-sig') as csv_file:
        data = json.load(json_file)
        if data:
            writer = csv.DictWriter(csv_file, fieldnames=data[0].keys())
            writer.writeheader()
            writer.writerows(data)

def json_to_html():
    with json_path.open('r', encoding='utf-8') as json_file, html_path.open('w', encoding='utf-8') as html_file:
        data = json.load(json_file)
        html_file.write('''
<!DOCTYPE html>
<html>
<head>
    <title>Security Check Results</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 0;
            padding: 20px;
            background-color: #f4f4f4;
        }
        h1 {
            color: #333;
        }
        table {
            width: 100%;
            border-collapse: collapse;
        }
        th, td {
            text-align: left;
            padding: 8px;
            border: 1px solid #ddd;
        }
        th {
            background-color: #4CAF50;
            color: white;
        }
        tr:nth-child(even) {
            background-color: #f2f2f2;
        }
    </style>
</head>
<body>
    <h1>Security Check Results</h1>
    <a href=\"''' + csv_path.name + '''\">Download CSV</a><br>
    <table>''')
        if data:
            headers = data[0].keys()
            html_file.write('<tr>' + ''.join(f'<th>{h}</th>' for h in headers) + '</tr>')
            for item in data:
                row = '<tr>' + ''.join(f'<td>{item[h]}</td>' for h in headers) + '</tr>'
                html_file.write(row)
        html_file.write('</table></body></html>')

json_to_csv()
json_to_html()
"
    echo "결과가 CSV와 HTML 형식으로 변환되었습니다."
}


# Apache 서비스 재시작 개선된 버전
restart_apache() {
    local service_names=("apache2.service" "httpd.service") # 서비스 파일 이름 명시
    local service_found=false

    for name in "${service_names[@]}"; do
        # 시스템에 서비스 파일이 존재하는지 확인
        if systemctl list-unit-files | grep -qw "$name"; then
            echo "$name 서비스를 재시작합니다."
            if sudo systemctl restart "$name"; then
                echo "$name 서비스가 성공적으로 재시작되었습니다."
                service_found=true
                break
            else
                echo "$name 서비스 재시작에 실패했습니다."
            fi
        fi
    done

    if [ "$service_found" = false ]; then
        echo "Apache/Httpd 서비스를 찾을 수 없습니다. 시스템에 서비스가 설치되어 있는지 확인해주세요."
    fi
}



# 메인 로직 실행
main() {
    setup_environment
    setup_apache_encoding # 인코딩 설정 함수 호출
    execute_security_checks 
    convert_results  # 이 부분을 수정했습니다.
    restart_apache
}

main


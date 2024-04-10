#!/bin/bash

# 시스템 업데이트 및 보안 패치 적용
sudo apt-get update
upgrade_output=$(sudo apt-get upgrade -y)
security_upgrade_output=$(sudo apt-get dist-upgrade -y)

# 결과 출력
cat $results_file

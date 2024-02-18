#!/bin/bash

. function.sh

BAR

CODE [U-23] DoS 공격에 취약한 서비스 비활성화		

cat << EOF >> $result

[양호]: 사용하지 않는 DoS 공격에 취약한 서비스가 비활성화 된 경우

[취약]: 사용하지 않는 DoS 공격에 취약한 서비스가 활성화 된 경우

EOF

BAR

# echo 파일 생성
echo "service echo
{
disable = yes
id = echo-stream
type = internal
wait = no
socket_type = stream
}" > /etc/xinetd.d/echo

# discard 파일 생성
echo "service discard
{
disable = yes
id = echo-stream
type = internal
wait = no
socket_type = stream
}" > /etc/xinetd.d/discard

# daytime 파일 생성
echo "service daytime
{
disable = yes
id = echo-stream
type = internal
wait = no
socket_type = stream
}" > /etc/xinetd.d/daytime

# daytime 파일 생성
echo "service chargen
{
disable = yes
id = echo-stream
type = internal
wait = no
socket_type = stream
}" > /etc/xinetd.d/chargen

cat $result

echo ; echo

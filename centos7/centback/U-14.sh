#!/bin/bash

. function.sh

BAR

CODE [U-14] 사용자, 시스템 시작파일 및 환경파일 소유자 및 권한 설정		

cat << EOF >> $result

[양호]: 홈 디렉터리 환경변수 파일 소유자가 root 또는, 해당 계정으로 지정되
어 있고, 홈 디렉터리 환경변수 파일에 root와 소유자만 쓰기 권한이 부여
된 경우

[취약]: 홈 디렉터리 환경변수 파일 소유자가 root 또는, 해당 계정으로 지정되
지 않고, 홈 디렉터리 환경변수 파일에 root와 소유자 외에 쓰기 권한이 
부여된 경우

EOF

BAR

TMP1=`SCRIPTNAME`.log

>$TMP1  

#    백업 파일 생성
cp $HOME/.profile.bak $HOME/.profile
cp $HOME/.kshrc.bak $HOME/.kshrc
cp $HOME/.cshrc.bak $HOME/.cshrc
cp $HOME/.bashrc.bak $HOME/.bashrc
cp $HOME/.bash_profile.bak $HOME/.bash_profile
cp $HOME/.login.bak $HOME/.login
cp $HOME/.exrc.bak $HOME/.exrc
cp $HOME/.netrc.bak $HOME/.netrc


cat $result

echo ; echo

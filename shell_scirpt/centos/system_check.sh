#!/bin/bash


. function.sh


# 1) 변수 설정 및 초기화
PermList=perm.list # 점검 대상 파일 목록
Result=report2.txt # 점검 결과
TMP1=/tmp/tmp1

> $Result # 파일 실행 시 점검 결과 초기화
> $TMP1 # 파일 실행 시 임시 파일 초기화

# 2) 파일 유무 점검
for ChkFile in `cat $PermList | awk '{print $1}'`
do
if [ ! -f $ChkFile ] ; then
echo "[ WARN ] '$ChkFile' not found."
exit 1
break
fi
done


# 3) 점검 스크립트
cat $PermList | while read FName FAuth FPermNum FPermChar
do
if [ ! -f $FName ] ; then
echo "[ ERROR ] $FName not found" >> $Result
echo >> $Result
continue
else
find $FName -type f -perm -$FPermNum -ls | fgrep -v $FPermChar > $TMP1
if [ -s $TMP1 ] ; then
BadPerm=$(cat $TMP1 | awk '{print $3}')
WARN "$FPermNum : $FName ($BadPerm)" >> $Result
else
GoodPerm=$(find $FName -type f -ls | awk '{print $3}')
OK "$FPermNum : $FName ($GoodPerm)" >> $Result
fi
fi
done

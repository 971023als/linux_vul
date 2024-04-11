#!/bin/bash

# /etc/exports 파일이 존재하는지 확인
if [ ! -f "/etc/exports" ]; then
    echo "/etc/exports 파일이 존재하지 않습니다. NFS 설정을 검토해주세요."
    exit 1
fi

# /etc/exports 파일 백업
cp /etc/exports /etc/exports.backup
echo "/etc/exports 파일의 백업을 완료했습니다."

# '*' 사용 제한 (everyone 공유 제한)
sed -i '/\*/d' /etc/exports
echo "everyone 공유를 제한했습니다. '*' 사용이 제거되었습니다."

# 'insecure' 옵션 제거
sed -i 's/insecure//g' /etc/exports
echo "'insecure' 옵션이 제거되었습니다."

# 'root_squash'와 'all_squash' 옵션 적용 여부 확인 및 추가
while IFS= read -r line; do
    if [[ ! $line =~ root_squash ]] && [[ ! $line =~ all_squash ]]; then
        # 현재 줄에 root_squash나 all_squash 옵션이 없는 경우 root_squash 추가
        sed -i "s|$line|$line,root_squash|g" /etc/exports
    fi
done < /etc/exports
echo "'root_squash' 및 'all_squash' 옵션이 적용되었습니다."

# NFS 서비스 재시작
systemctl restart nfs-server
echo "NFS 서비스를 재시작했습니다."

echo "U-25 /etc/exports 파일의 보안 조치가 완료되었습니다."

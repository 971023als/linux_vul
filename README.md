# Linux 서버 취약점 진단 자동화 스크립트

이 프로젝트는 주요 정보통신 기반시설의 보안 강화를 위해 Linux 서버 취약점을 점검하고 평가하는 자동화 스크립트를 제공합니다. 목표는 서버의 보안 상태를 평가하여 취약한 부분을 식별하고, 보안 조치를 취할 수 있도록 하는 것입니다.

## 1. 주요 정보통신 기반시설 취약점 점검 항목 (Linux 서버)

이 프로젝트는 다음과 같은 Linux 서버 취약점 점검 항목을 포함합니다:

- 사용자 계정 및 권한 설정
- 파일 및 디렉토리 권한 설정
- 시스템 패치 및 업데이트 상태
- 네트워크 설정 및 서비스 관리
- 로깅 및 감사 정책
- 암호 정책 및 인증 방식
- 방화벽 및 보안 그룹 설정

## 2. 자동화 스크립트를 통한 진단 가능 부분

자동화 스크립트를 통해 진단 가능한 부분은 다음과 같습니다:

- 사용자 계정 및 권한 검사
- 파일 및 디렉토리 권한 검사
- 시스템 패치 수준 확인
- 불필요한 서비스 및 네트워크 포트 확인
- 시스템 로깅 및 감사 설정 확인
- 암호화 정책 및 인증 설정 검사

## 3. 자동화 스크립트 작성

스크립트는 쉘스크립트(.sh) 또는 파이썬(.py)으로 작성할 수 있으며, 점검 항목에 대한 진단 로직을 포함해야 합니다. 자동화 스크립트는 시스템을 점검하고 각 항목의 상태를 확인한 후, 결과를 JSON 형태로 출력합니다.

## 4. 결과 파일

진단 스크립트는 다음 형태의 JSON 결과 파일을 생성합니다:

```json
{
  "점검항목명": {
    "status": "취약" | "양호",
    "description": "항목에 대한 설명 및 조치 사항"
  },
  ...
}
```


```python
cd root
```

```python
sudo yum install git
```

```python
sudo apt-get install git
```


```python
sudo git clone https://github.com/971023als/linux_vul
```

## 5-1 파이썬 진단 스크립트 실행방법(ubuntu 기준)
```python
cd linux_vul/Python_json/ubuntu/
```


## 5-2 파이썬 진단 스크립트 실행방법(centos 기준)

```python
cd linux_vul/Python_json/centos/
```

## 5-3 파이썬 진단 스크립트 실행방법(Fedora 기준)

```python
cd linux_vul/Python_json/Fedora/
```

## 5-4 파이썬 진단 스크립트 실행방법(Rocky 기준)
```python
cd linux_vul/Python_json/Rocky/
```

## 5-5 쉘스크립트 진단 스크립트 실행방법(ubuntu 기준)
```python
cd linux_vul/shell scirpt/ubuntu/
```

## 5-6 쉘스크립트 진단 스크립트 실행방법(centos 기준)
```python
cd linux_vul/shell scirpt/centos/
```

## 5-7 쉘스크립트 진단 스크립트 실행방법(Fedora 기준)
```python
cd linux_vul/shell scirpt/Fedora/
```

## 5-8 쉘스크립트 진단 스크립트 실행방법(Rocky 기준)
```python
cd linux_vul/shell scirpt/Rocky/
```

## 5-9 쉘스크립트 조치 스크립트 실행방법(ubuntu 기준)
```python
cd linux_vul/change/
```

```python
chmod +x vul.sh
```


```python
./vul.sh
```

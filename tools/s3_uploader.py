#!/usr/bin/env python3
"""
tools/s3_uploader.py — 감사 결과 S3 업로드
output/ 디렉터리 또는 단일 파일을 S3에 업로드.

사용:
  python3 s3_uploader.py --path output/ --bucket my-bucket --hostname web-01
  python3 s3_uploader.py --path output/html/report.html --bucket my-bucket

환경변수:
  AWS_DEFAULT_REGION  : AWS 리전 (기본: ap-northeast-2)
  AWS_PROFILE         : AWS 프로파일 (선택)
"""
import argparse
import os
import sys
from datetime import datetime
from pathlib import Path

import boto3
from botocore.exceptions import BotoCoreError, ClientError


def get_s3_client(region: str):
    """region을 명시해 S3 클라이언트를 초기화. VPC 엔드포인트 환경에서도 올바른 리전 사용."""
    return boto3.client("s3", region_name=region)


def upload_directory(path: str, bucket: str, s3_prefix: str, region: str) -> int:
    """디렉터리를 S3에 재귀 업로드. 실패한 파일 수를 반환."""
    s3 = get_s3_client(region)
    errors = 0
    total = 0
    for root, _dirs, files in os.walk(path):
        for file in files:
            local_path = os.path.join(root, file)
            relative_path = os.path.relpath(local_path, path)
            s3_key = os.path.join(s3_prefix, relative_path).replace("\\", "/")
            total += 1
            try:
                s3.upload_file(local_path, bucket, s3_key)
                print(f"[S3] Uploaded: {local_path} → s3://{bucket}/{s3_key}")
            except (BotoCoreError, ClientError, OSError) as e:
                print(f"[S3] ERROR uploading {local_path}: {e}", file=sys.stderr)
                errors += 1
    print(f"[S3] 완료: {total - errors}/{total} 성공" + (f", {errors} 실패" if errors else ""))
    return errors


def upload_file(path: str, bucket: str, s3_prefix: str, region: str) -> int:
    """단일 파일을 S3에 업로드. 실패 시 1 반환."""
    s3 = get_s3_client(region)
    s3_key = f"{s3_prefix}/{Path(path).name}"
    try:
        s3.upload_file(path, bucket, s3_key)
        print(f"[S3] Uploaded: {path} → s3://{bucket}/{s3_key}")
        return 0
    except (BotoCoreError, ClientError, OSError) as e:
        print(f"[S3] ERROR uploading {path}: {e}", file=sys.stderr)
        return 1


def main() -> None:
    parser = argparse.ArgumentParser(description="Upload audit results to AWS S3")
    parser.add_argument("--path",     required=True,  help="업로드할 로컬 디렉터리 또는 파일")
    parser.add_argument("--bucket",   required=True,  help="대상 S3 버킷명")
    parser.add_argument("--hostname", default="unknown-host", help="S3 경로 구성용 호스트명")
    parser.add_argument("--region",
                        default=os.environ.get("AWS_DEFAULT_REGION", "ap-northeast-2"),
                        help="AWS 리전 (기본: AWS_DEFAULT_REGION 환경변수 또는 ap-northeast-2)")
    args = parser.parse_args()

    if not os.path.exists(args.path):
        print(f"[ERROR] 경로를 찾을 수 없음: {args.path}", file=sys.stderr)
        sys.exit(1)

    date_str  = datetime.now().strftime("%Y-%m-%d_%H%M%S")
    s3_prefix = f"audits/{args.hostname}/{date_str}"

    print(f"[S3] 대상 버킷 : s3://{args.bucket}/{s3_prefix}/")
    print(f"[S3] 리전      : {args.region}")

    if os.path.isdir(args.path):
        errors = upload_directory(args.path, args.bucket, s3_prefix, args.region)
    else:
        errors = upload_file(args.path, args.bucket, s3_prefix, args.region)

    if errors:
        print(f"[S3] {errors}개 파일 업로드 실패.", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()

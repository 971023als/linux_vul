import boto3
import os
import argparse
from datetime import datetime

def get_s3_client():
    """Initialize S3 client. Uses environment variables or IAM role."""
    return boto3.client('s3')

def upload_directory(path, bucket, s3_prefix):
    """Recursively upload a directory to S3."""
    s3 = get_s3_client()
    for root, dirs, files in os.walk(path):
        for file in files:
            local_path = os.path.join(root, file)
            relative_path = os.path.relpath(local_path, path)
            s3_key = os.path.join(s3_prefix, relative_path).replace("\\", "/")
            
            try:
                s3.upload_file(local_path, bucket, s3_key)
                print(f"[S3] Uploaded: {local_path} -> s3://{bucket}/{s3_key}")
            except Exception as e:
                print(f"[S3] Error uploading {local_path}: {e}")

def main():
    parser = argparse.ArgumentParser(description="Upload audit results to AWS S3")
    parser.add_argument("--path", required=True, help="Local directory or file to upload")
    parser.add_argument("--bucket", required=True, help="Target S3 bucket name")
    parser.add_argument("--hostname", default="unknown-host", help="Hostname for S3 path structure")
    
    args = parser.parse_args()
    
    date_str = datetime.now().strftime('%Y-%m-%d_%H%M%S')
    s3_prefix = f"audits/{args.hostname}/{date_str}"
    
    if os.path.isdir(args.path):
        upload_directory(args.path, args.bucket, s3_prefix)
    else:
        s3 = get_s3_client()
        s3_key = f"{s3_prefix}/{os.path.basename(args.path)}"
        s3.upload_file(args.path, args.bucket, s3_key)
        print(f"[S3] Uploaded: {args.path} -> s3://{args.bucket}/{s3_key}")

if __name__ == "__main__":
    main()

// internal/s3util/client.go
// S3에서 linux-vul 진단 결과 MD 파일 다운로드 + 디버그 로깅

package s3util

import (
	"context"
	"fmt"
	"io"
	"os"
	"path/filepath"
	"strings"
	"time"

	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/config"
	awss3 "github.com/aws/aws-sdk-go-v2/service/s3"
	"github.com/linux-vul/ssm-runner/internal/debug"
)

// ClientConfig S3 클라이언트 설정
type ClientConfig struct {
	Region      string
	EndpointURL string
}

// Client S3 래퍼
type Client struct {
	svc *awss3.Client
}

// FetchRequest S3 다운로드 파라미터
type FetchRequest struct {
	Bucket     string
	Prefix     string
	Profile    string
	CheckID    string
	InstanceID string
	OutputDir  string
}

// NewClient S3 클라이언트 생성
func NewClient(ctx context.Context, cfg ClientConfig) (*Client, error) {
	debug.Section("s3util.NewClient")
	debug.F("Region=%s  EndpointURL=%q", cfg.Region, cfg.EndpointURL)

	opts := []func(*config.LoadOptions) error{
		config.WithRegion(cfg.Region),
	}

	loadStart := time.Now()
	awsCfg, err := config.LoadDefaultConfig(ctx, opts...)
	if err != nil {
		debug.F("LoadDefaultConfig 실패: %v", err)
		return nil, fmt.Errorf("AWS config 로드 실패: %w", err)
	}
	debug.F("AWS config 로드 완료: %dms  region=%s", time.Since(loadStart).Milliseconds(), awsCfg.Region)

	var svcOpts []func(*awss3.Options)
	if cfg.EndpointURL != "" {
		debug.F("VPC 엔드포인트 설정: %s  path-style=true", cfg.EndpointURL)
		svcOpts = append(svcOpts, func(o *awss3.Options) {
			o.BaseEndpoint = aws.String(cfg.EndpointURL)
			o.UsePathStyle = true
		})
	} else {
		debug.F("S3 엔드포인트: AWS 기본값 사용")
	}

	svc := awss3.NewFromConfig(awsCfg, svcOpts...)
	debug.F("S3 클라이언트 생성 완료")
	return &Client{svc: svc}, nil
}

// Fetch S3에서 조건에 맞는 MD 파일을 모두 다운로드
func (c *Client) Fetch(ctx context.Context, req FetchRequest) ([]string, error) {
	debug.Section("s3util.Fetch")
	debug.F("bucket=%s  prefix=%s  profile=%s  checkFilter=%q  instanceFilter=%q  outputDir=%s",
		req.Bucket, req.Prefix, req.Profile, req.CheckID, req.InstanceID, req.OutputDir)

	// S3 프리픽스 구성
	s3Prefix := req.Prefix
	if !strings.HasSuffix(s3Prefix, "/") {
		s3Prefix += "/"
	}
	if req.Profile != "" {
		s3Prefix += req.Profile + "/"
	}
	debug.F("최종 S3 프리픽스: s3://%s/%s", req.Bucket, s3Prefix)

	checkFilter := ""
	if req.CheckID != "" {
		checkFilter = req.CheckID + "_"
		debug.F("CheckID 필터: %q", checkFilter)
	}
	if req.InstanceID != "" {
		debug.F("InstanceID 필터: %q", req.InstanceID)
	}

	var downloaded []string
	pageNum := 0
	totalObjects := 0
	filteredOut := 0

	paginator := awss3.NewListObjectsV2Paginator(c.svc, &awss3.ListObjectsV2Input{
		Bucket: aws.String(req.Bucket),
		Prefix: aws.String(s3Prefix),
	})

	debug.F("ListObjectsV2 시작: paginator 생성 완료")

	for paginator.HasMorePages() {
		pageNum++
		debug.F("ListObjectsV2 페이지 #%d 요청 중...", pageNum)

		pageStart := time.Now()
		page, err := paginator.NextPage(ctx)
		if err != nil {
			debug.F("ListObjectsV2 페이지 #%d 오류: %v  elapsed=%dms",
				pageNum, err, time.Since(pageStart).Milliseconds())
			return nil, fmt.Errorf("S3 ListObjects 실패 (prefix=%s): %w", s3Prefix, err)
		}
		debug.F("ListObjectsV2 페이지 #%d: %d 개 오브젝트  elapsed=%dms",
			pageNum, len(page.Contents), time.Since(pageStart).Milliseconds())

		for _, obj := range page.Contents {
			totalObjects++
			key := aws.ToString(obj.Key)
			fileName := filepath.Base(key)
			objSize := aws.ToInt64(obj.Size)

			debug.F("  오브젝트[%d]: key=%s  size=%d bytes  lastModified=%s",
				totalObjects, key, objSize,
				aws.ToTime(obj.LastModified).Format("2006-01-02 15:04:05"),
			)

			// .md 파일 필터
			if !strings.HasSuffix(fileName, ".md") {
				filteredOut++
				debug.F("    → 스킵: .md 아님 (%s)", filepath.Ext(fileName))
				continue
			}
			// CheckID 필터
			if checkFilter != "" && !strings.HasPrefix(fileName, checkFilter) {
				filteredOut++
				debug.F("    → 스킵: CheckID 불일치 (want prefix=%s)", checkFilter)
				continue
			}
			// InstanceID 필터
			if req.InstanceID != "" && !strings.Contains(fileName, req.InstanceID) {
				filteredOut++
				debug.F("    → 스킵: InstanceID 불일치 (want %s)", req.InstanceID)
				continue
			}

			debug.F("    → 다운로드 대상: %s (%d bytes)", fileName, objSize)

			dlStart := time.Now()
			localPath, err := c.downloadFile(ctx, req.Bucket, key, req.OutputDir, fileName)
			dlElapsed := time.Since(dlStart)
			if err != nil {
				debug.F("    → 다운로드 실패: %v  elapsed=%dms", err, dlElapsed.Milliseconds())
				fmt.Fprintf(os.Stderr, "[s3util] WARN: 다운로드 실패 %s: %v\n", key, err)
				continue
			}
			debug.F("    → 다운로드 완료: %s  elapsed=%dms", localPath, dlElapsed.Milliseconds())
			downloaded = append(downloaded, localPath)
		}
	}

	debug.F("Fetch 완료: 총 오브젝트=%d  필터제외=%d  다운로드=%d",
		totalObjects, filteredOut, len(downloaded))

	if len(downloaded) == 0 {
		debug.F("결과 없음: 조건에 맞는 파일 없음")
		fmt.Fprintf(os.Stderr, "[s3util] 조건에 맞는 파일 없음 (prefix=%s, check=%s, instance=%s)\n",
			s3Prefix, req.CheckID, req.InstanceID)
	}

	return downloaded, nil
}

// downloadFile 단일 S3 오브젝트 다운로드
func (c *Client) downloadFile(ctx context.Context, bucket, key, outputDir, fileName string) (string, error) {
	debug.F("downloadFile: s3://%s/%s → %s/%s", bucket, key, outputDir, fileName)

	if err := os.MkdirAll(outputDir, 0o755); err != nil {
		return "", fmt.Errorf("출력 디렉터리 생성 실패: %w", err)
	}

	localPath := filepath.Join(outputDir, fileName)
	debug.F("GetObject 요청: bucket=%s  key=%s", bucket, key)

	getStart := time.Now()
	result, err := c.svc.GetObject(ctx, &awss3.GetObjectInput{
		Bucket: aws.String(bucket),
		Key:    aws.String(key),
	})
	if err != nil {
		debug.F("GetObject 실패: %v  elapsed=%dms", err, time.Since(getStart).Milliseconds())
		return "", fmt.Errorf("GetObject 실패 (key=%s): %w", key, err)
	}
	defer result.Body.Close()

	contentLen := aws.ToInt64(result.ContentLength)
	debug.F("GetObject 응답: contentLength=%d  contentType=%s  elapsed=%dms",
		contentLen,
		aws.ToString(result.ContentType),
		time.Since(getStart).Milliseconds(),
	)

	f, err := os.Create(localPath)
	if err != nil {
		return "", fmt.Errorf("로컬 파일 생성 실패 (%s): %w", localPath, err)
	}
	defer f.Close()

	written, err := io.Copy(f, result.Body)
	if err != nil {
		debug.F("파일 쓰기 실패: %v  written=%d bytes", err, written)
		return "", fmt.Errorf("파일 쓰기 실패 (%s): %w", localPath, err)
	}
	debug.F("파일 저장 완료: %s  written=%d bytes", localPath, written)

	return localPath, nil
}

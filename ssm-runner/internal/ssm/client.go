// internal/ssm/client.go
// AWS SSM 클라이언트 — VPC 엔드포인트 지원 + 디버그 로깅

package ssm

import (
	"context"
	"fmt"
	"strings"
	"time"

	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/config"
	awsssm "github.com/aws/aws-sdk-go-v2/service/ssm"
	"github.com/aws/aws-sdk-go-v2/service/ssm/types"
	"github.com/linux-vul/ssm-runner/internal/debug"
)

// ClientConfig SSM 클라이언트 설정
type ClientConfig struct {
	Region      string
	EndpointURL string
}

// Client SSM 래퍼
type Client struct {
	svc *awsssm.Client
	cfg ClientConfig
}

// CommandResult SSM RunCommand 결과
type CommandResult struct {
	CommandID  string
	InstanceID string
	Status     string
	ExitCode   int
	Output     string
	StdErr     string
}

// InvocationStatus 상태 요약
type InvocationStatus struct {
	InstanceID string
	Status     string
	ExitCode   int
	Output     string
}

// RunSingleRequest 단일 체크 파라미터
type RunSingleRequest struct {
	InstanceID string
	CheckID    string
	Profile    string
	S3Bucket   string
	S3Prefix   string
	RepoPath   string
	Timeout    int
}

// RunFullRequest 전체 감사 파라미터
type RunFullRequest struct {
	InstanceID  string
	Profile     string
	S3Bucket    string
	S3Prefix    string
	RepoPath    string
	Timeout     int
	RunPipeline bool
	Force       bool
}

// =============================================================================
// NewClient SSM 클라이언트 생성
// =============================================================================

func NewClient(ctx context.Context, cfg ClientConfig) (*Client, error) {
	debug.Section("ssm.NewClient")
	debug.F("Region=%s  EndpointURL=%q", cfg.Region, cfg.EndpointURL)

	opts := []func(*config.LoadOptions) error{
		config.WithRegion(cfg.Region),
	}

	debug.F("AWS 기본 설정 로드 중 (credentials chain: env → profile → IMDS)")
	loadStart := time.Now()
	awsCfg, err := config.LoadDefaultConfig(ctx, opts...)
	if err != nil {
		debug.F("LoadDefaultConfig 실패: %v", err)
		return nil, fmt.Errorf("AWS config 로드 실패: %w", err)
	}
	debug.F("AWS config 로드 완료: %dms  region=%s", time.Since(loadStart).Milliseconds(), awsCfg.Region)

	var svcOpts []func(*awsssm.Options)
	if cfg.EndpointURL != "" {
		debug.F("VPC 엔드포인트 설정: %s", cfg.EndpointURL)
		svcOpts = append(svcOpts, func(o *awsssm.Options) {
			o.BaseEndpoint = aws.String(cfg.EndpointURL)
		})
	} else {
		debug.F("엔드포인트: AWS 기본값 사용 (public)")
	}

	svc := awsssm.NewFromConfig(awsCfg, svcOpts...)
	debug.F("SSM 서비스 클라이언트 생성 완료")
	return &Client{svc: svc, cfg: cfg}, nil
}

// =============================================================================
// RunSingle — 단일 U-xx 체크를 SSM RunCommand로 전송
// =============================================================================

func (c *Client) RunSingle(ctx context.Context, req RunSingleRequest) (string, error) {
	debug.Section("ssm.RunSingle")
	debug.F("instance=%s  check=%s  profile=%s  bucket=%q  timeout=%ds",
		req.InstanceID, req.CheckID, req.Profile, req.S3Bucket, req.Timeout)

	script := buildSingleScript(req)
	debug.F("인라인 스크립트 생성 완료: %d bytes", len(script))
	debug.F("스크립트 첫 3줄:\n%s", firstNLines(script, 3))

	input := &awsssm.SendCommandInput{
		InstanceIds:  []string{req.InstanceID},
		DocumentName: aws.String("AWS-RunShellScript"),
		Parameters: map[string][]string{
			"commands":         {script},
			"executionTimeout": {fmt.Sprintf("%d", req.Timeout)},
		},
		Comment:        aws.String(fmt.Sprintf("linux-vul %s on %s", req.CheckID, req.InstanceID)),
		TimeoutSeconds: aws.Int32(int32(req.Timeout + 30)),
		CloudWatchOutputConfig: &types.CloudWatchOutputConfig{
			CloudWatchOutputEnabled: true,
			CloudWatchLogGroupName:  aws.String("/aws/ssm/linux-vul-single-check"),
		},
	}
	debug.F("SendCommand 요청: document=%s instances=%v timeout=%ds",
		aws.ToString(input.DocumentName), input.InstanceIds, req.Timeout)

	sendStart := time.Now()
	out, err := c.svc.SendCommand(ctx, input)
	elapsed := time.Since(sendStart)
	if err != nil {
		debug.F("SendCommand API 오류: %v  elapsed=%dms", err, elapsed.Milliseconds())
		return "", fmt.Errorf("SendCommand 실패: %w", err)
	}
	if out.Command == nil {
		debug.F("SendCommand 응답에 Command 필드 없음 (nil)")
		return "", fmt.Errorf("SendCommand 응답 비정상: Command 필드 없음")
	}

	cmdID := aws.ToString(out.Command.CommandId)
	debug.F("SendCommand 성공: commandId=%s  status=%s  elapsed=%dms",
		cmdID, string(out.Command.Status), elapsed.Milliseconds())

	return cmdID, nil
}

// =============================================================================
// RunFull — 전체 U-01~U-72 감사를 SSM RunCommand로 전송
// =============================================================================

func (c *Client) RunFull(ctx context.Context, req RunFullRequest) (string, error) {
	debug.Section("ssm.RunFull")
	debug.F("instance=%s  profile=%s  pipeline=%v  force=%v  timeout=%ds",
		req.InstanceID, req.Profile, req.RunPipeline, req.Force, req.Timeout)

	script := buildFullScript(req)
	debug.F("인라인 스크립트 생성: %d bytes", len(script))
	debug.F("스크립트 첫 3줄:\n%s", firstNLines(script, 3))

	input := &awsssm.SendCommandInput{
		InstanceIds:  []string{req.InstanceID},
		DocumentName: aws.String("AWS-RunShellScript"),
		Parameters: map[string][]string{
			"commands":         {script},
			"executionTimeout": {fmt.Sprintf("%d", req.Timeout)},
		},
		Comment:        aws.String(fmt.Sprintf("linux-vul full audit on %s", req.InstanceID)),
		TimeoutSeconds: aws.Int32(int32(req.Timeout + 60)),
		CloudWatchOutputConfig: &types.CloudWatchOutputConfig{
			CloudWatchOutputEnabled: true,
			CloudWatchLogGroupName:  aws.String("/aws/ssm/linux-vul-full-audit"),
		},
	}
	debug.F("SendCommand 요청: document=%s  instances=%v",
		aws.ToString(input.DocumentName), input.InstanceIds)

	sendStart := time.Now()
	out, err := c.svc.SendCommand(ctx, input)
	elapsed := time.Since(sendStart)
	if err != nil {
		debug.F("SendCommand API 오류: %v  elapsed=%dms", err, elapsed.Milliseconds())
		return "", fmt.Errorf("SendCommand 실패: %w", err)
	}
	if out.Command == nil {
		debug.F("SendCommand 응답에 Command 필드 없음 (nil)")
		return "", fmt.Errorf("SendCommand 응답 비정상: Command 필드 없음")
	}

	cmdID := aws.ToString(out.Command.CommandId)
	debug.F("SendCommand 성공: commandId=%s  status=%s  elapsed=%dms",
		cmdID, string(out.Command.Status), elapsed.Milliseconds())

	return cmdID, nil
}

// =============================================================================
// WaitForCommand — 완료될 때까지 폴링
// =============================================================================

func (c *Client) WaitForCommand(ctx context.Context, cmdID, instanceID string, timeoutSecs int) (*CommandResult, error) {
	debug.Section("ssm.WaitForCommand")
	debug.F("commandId=%s  instanceId=%q  timeout=%ds", cmdID, instanceID, timeoutSecs)

	deadline := time.Now().Add(time.Duration(timeoutSecs) * time.Second)
	pollInterval := 5 * time.Second
	attempt := 0

	for time.Now().Before(deadline) {
		// ctx 취소/타임아웃 즉시 반영 (외부 cancel이 내부 deadline보다 우선)
		select {
		case <-ctx.Done():
			debug.F("WaitForCommand ctx 취소: %v  commandId=%s  총 시도=%d", ctx.Err(), cmdID, attempt)
			return nil, fmt.Errorf("컨텍스트 취소됨: %w (commandId=%s)", ctx.Err(), cmdID)
		default:
		}

		attempt++
		debug.F("폴링 #%d: commandId=%s  남은시간=%.0fs",
			attempt, cmdID, time.Until(deadline).Seconds())

		pollStart := time.Now()
		invocations, err := c.GetCommandStatus(ctx, cmdID, instanceID)
		pollElapsed := time.Since(pollStart)

		if err != nil {
			debug.F("폴링 #%d 오류: %v  elapsed=%dms", attempt, err, pollElapsed.Milliseconds())
			return nil, err
		}
		debug.F("폴링 #%d 응답: %d invocation(s)  elapsed=%dms",
			attempt, len(invocations), pollElapsed.Milliseconds())

		if len(invocations) == 0 {
			debug.F("폴링 #%d: invocation 없음 — %s 후 재시도", attempt, pollInterval)
			select {
			case <-ctx.Done():
				debug.F("Sleep 중 ctx 취소: %v", ctx.Err())
				return nil, fmt.Errorf("컨텍스트 취소됨: %w (commandId=%s)", ctx.Err(), cmdID)
			case <-time.After(pollInterval):
			}
			continue
		}

		inv := invocations[0]
		debug.F("폴링 #%d: instance=%s  status=%s  exit=%d  outputLen=%d",
			attempt, inv.InstanceID, inv.Status, inv.ExitCode, len(inv.Output))

		switch inv.Status {
		case "Success", "Failed", "Cancelled", "TimedOut":
			exitCode := inv.ExitCode
			if inv.Status != "Success" && exitCode == 0 {
				exitCode = 1
			}
			debug.F("터미널 상태 감지: %s  finalExit=%d  totalAttempts=%d",
				inv.Status, exitCode, attempt)
			return &CommandResult{
				CommandID:  cmdID,
				InstanceID: inv.InstanceID,
				Status:     inv.Status,
				ExitCode:   exitCode,
				Output:     inv.Output,
			}, nil
		default:
			fmt.Printf("  [폴링 #%d] %s — 상태: %s\n", attempt, cmdID[:8], inv.Status)
			debug.F("폴링 #%d: 비터미널 상태=%s — %s 후 재시도", attempt, inv.Status, pollInterval)
		}

		// 인터럽트 가능한 Sleep
		select {
		case <-ctx.Done():
			debug.F("Sleep 중 ctx 취소: %v", ctx.Err())
			return nil, fmt.Errorf("컨텍스트 취소됨: %w (commandId=%s)", ctx.Err(), cmdID)
		case <-time.After(pollInterval):
		}
	}

	debug.F("WaitForCommand 타임아웃: %ds  총 시도=%d", timeoutSecs, attempt)
	return nil, fmt.Errorf("타임아웃: %d초 내에 완료되지 않음 (commandId=%s)", timeoutSecs, cmdID)
}

// =============================================================================
// GetCommandStatus — 현재 상태 조회
// =============================================================================

func (c *Client) GetCommandStatus(ctx context.Context, cmdID, instanceID string) ([]InvocationStatus, error) {
	debug.F("GetCommandStatus: commandId=%s  instanceId=%q", cmdID, instanceID)

	input := &awsssm.ListCommandInvocationsInput{
		CommandId: aws.String(cmdID),
		Details:   true,
	}
	if instanceID != "" {
		input.InstanceId = aws.String(instanceID)
		debug.F("GetCommandStatus: 특정 인스턴스 필터 적용")
	}

	apiStart := time.Now()
	out, err := c.svc.ListCommandInvocations(ctx, input)
	elapsed := time.Since(apiStart)
	if err != nil {
		debug.F("ListCommandInvocations 오류: %v  elapsed=%dms", err, elapsed.Milliseconds())
		return nil, fmt.Errorf("ListCommandInvocations 실패: %w", err)
	}
	debug.F("ListCommandInvocations 응답: %d 건  elapsed=%dms",
		len(out.CommandInvocations), elapsed.Milliseconds())

	var results []InvocationStatus
	for idx, inv := range out.CommandInvocations {
		exitCode := 0
		output := ""

		for _, plugin := range inv.CommandPlugins {
			exitCode = int(aws.ToInt32(plugin.ResponseCode))
			output = aws.ToString(plugin.Output)
			debug.F("  invocation[%d]: instance=%s status=%s plugin=%s exit=%d outputLen=%d",
				idx,
				aws.ToString(inv.InstanceId),
				string(inv.Status),
				aws.ToString(plugin.Name),
				exitCode,
				len(output),
			)
			break
		}

		results = append(results, InvocationStatus{
			InstanceID: aws.ToString(inv.InstanceId),
			Status:     string(inv.Status),
			ExitCode:   exitCode,
			Output:     output,
		})
	}

	return results, nil
}

// =============================================================================
// 내부 헬퍼
// =============================================================================

// firstNLines 스크립트 첫 N줄 반환 (디버그 미리보기용)
func firstNLines(s string, n int) string {
	lines := strings.SplitN(s, "\n", n+1)
	if len(lines) > n {
		lines = lines[:n]
	}
	return strings.Join(lines, "\n")
}

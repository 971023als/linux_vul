// cmd/ssm-runner/main.go
// SSM Runner CLI — linux-vul-assessor 원격 실행 도구
//
// Usage:
//   ssm-runner [--debug] run single --instance i-xxx --check U-01 --profile ubuntu --bucket my-bucket
//   ssm-runner [--debug] run full   --instance i-xxx --profile ubuntu --bucket my-bucket
//   ssm-runner [--debug] status     --command-id xxxxxxxx
//   ssm-runner [--debug] fetch      --instance i-xxx --bucket my-bucket [--check U-01] [--output ./results]

package main

import (
	"context"
	"fmt"
	"os"
	"time"

	"github.com/linux-vul/ssm-runner/internal/debug"
	"github.com/linux-vul/ssm-runner/internal/s3util"
	"github.com/linux-vul/ssm-runner/internal/ssm"
	"github.com/spf13/cobra"
)

// ─── 공통 플래그 ──────────────────────────────────────────────────────────────

var (
	flagDebug       bool
	flagRegion      string
	flagSSMEndpoint string
	flagS3Endpoint  string
)

// ─── run single 플래그 ────────────────────────────────────────────────────────

var (
	flagInstance string
	flagCheckID  string
	flagProfile  string
	flagBucket   string
	flagPrefix   string
	flagRepoPath string
	flagTimeout  int
	flagNoWait   bool
)

// ─── run full 플래그 ──────────────────────────────────────────────────────────

var (
	flagRunPipeline bool
	flagForce       bool
)

// ─── status 플래그 ────────────────────────────────────────────────────────────

var flagCommandID string

// ─── fetch 플래그 ─────────────────────────────────────────────────────────────

var (
	flagFetchCheck string
	flagOutputDir  string
)

// =============================================================================
// Root command
// =============================================================================

var rootCmd = &cobra.Command{
	Use:   "ssm-runner",
	Short: "linux-vul-assessor SSM 원격 실행 도구",
	Long: `SSM RunCommand를 사용해 EC2 인스턴스에서 linux-vul 체크를 실행합니다.

내부망 VPC 엔드포인트 사용 예시:
  ssm-runner --debug \
             --ssm-endpoint https://ssm.ap-northeast-2.amazonaws.com \
             --s3-endpoint  https://s3.ap-northeast-2.amazonaws.com \
             run single --instance i-xxx --check U-01 --profile ubuntu --bucket my-bucket`,
	PersistentPreRun: func(cmd *cobra.Command, args []string) {
		// --debug 플래그 처리 (모든 서브커맨드 공통)
		if flagDebug {
			debug.Enable()
		}
		if debug.Enabled() {
			debug.Section("ssm-runner 시작")
			debug.F("버전 빌드 시각: %s", time.Now().Format("2006-01-02 15:04:05"))
			debug.F("실행 커맨드: %s", cmd.CommandPath())
			debug.F("Region=%s  SSMEndpoint=%q  S3Endpoint=%q",
				flagRegion, flagSSMEndpoint, flagS3Endpoint)
			debug.F("환경변수: AWS_DEFAULT_REGION=%s  S3_BUCKET=%s",
				envOr("AWS_DEFAULT_REGION", "<unset>"),
				envOr("S3_BUCKET", "<unset>"),
			)
		}
	},
}

func init() {
	rootCmd.PersistentFlags().BoolVar(&flagDebug, "debug", false, "디버그 로그 활성화 (stderr 출력)")
	rootCmd.PersistentFlags().StringVar(&flagRegion, "region", envOr("AWS_DEFAULT_REGION", "ap-northeast-2"), "AWS 리전")
	rootCmd.PersistentFlags().StringVar(&flagSSMEndpoint, "ssm-endpoint", envOr("SSM_ENDPOINT_URL", ""), "SSM VPC 엔드포인트 URL")
	rootCmd.PersistentFlags().StringVar(&flagS3Endpoint, "s3-endpoint", envOr("S3_ENDPOINT_URL", ""), "S3 VPC 엔드포인트 URL")

	// run command
	rootCmd.AddCommand(runCmd)
	runCmd.AddCommand(runSingleCmd)
	runCmd.AddCommand(runFullCmd)

	// run single flags
	runSingleCmd.Flags().StringVar(&flagInstance, "instance", "", "(필수) EC2 인스턴스 ID")
	runSingleCmd.Flags().StringVar(&flagCheckID, "check", "", "(필수) 체크 ID, 예: U-01")
	runSingleCmd.Flags().StringVar(&flagProfile, "profile", "ubuntu", "OS 프로파일")
	runSingleCmd.Flags().StringVar(&flagBucket, "bucket", envOr("S3_BUCKET", ""), "S3 버킷명")
	runSingleCmd.Flags().StringVar(&flagPrefix, "prefix", envOr("S3_PREFIX", "linux-vul/results"), "S3 키 프리픽스")
	runSingleCmd.Flags().StringVar(&flagRepoPath, "repo", "/opt/linux_vul", "인스턴스 내 linux_vul 경로")
	runSingleCmd.Flags().IntVar(&flagTimeout, "timeout", 120, "명령 실행 타임아웃 (초)")
	runSingleCmd.Flags().BoolVar(&flagNoWait, "no-wait", false, "결과 대기 없이 command-id만 반환")
	_ = runSingleCmd.MarkFlagRequired("instance")
	_ = runSingleCmd.MarkFlagRequired("check")

	// run full flags
	runFullCmd.Flags().StringVar(&flagInstance, "instance", "", "(필수) EC2 인스턴스 ID")
	runFullCmd.Flags().StringVar(&flagProfile, "profile", "ubuntu", "OS 프로파일")
	runFullCmd.Flags().StringVar(&flagBucket, "bucket", envOr("S3_BUCKET", ""), "S3 버킷명")
	runFullCmd.Flags().StringVar(&flagPrefix, "prefix", envOr("S3_PREFIX", "linux-vul/results"), "S3 키 프리픽스")
	runFullCmd.Flags().StringVar(&flagRepoPath, "repo", "/opt/linux_vul", "인스턴스 내 linux_vul 경로")
	runFullCmd.Flags().IntVar(&flagTimeout, "timeout", 7200, "명령 실행 타임아웃 (초)")
	runFullCmd.Flags().BoolVar(&flagRunPipeline, "pipeline", true, "감사 후 normalize→csv→report 파이프라인 실행")
	runFullCmd.Flags().BoolVar(&flagForce, "force", false, "OS 프로파일 불일치 무시")
	runFullCmd.Flags().BoolVar(&flagNoWait, "no-wait", false, "결과 대기 없이 command-id만 반환")
	_ = runFullCmd.MarkFlagRequired("instance")

	// status command
	rootCmd.AddCommand(statusCmd)
	statusCmd.Flags().StringVar(&flagCommandID, "command-id", "", "(필수) SSM Command ID")
	statusCmd.Flags().StringVar(&flagInstance, "instance", "", "(선택) 특정 인스턴스 결과만 조회")
	_ = statusCmd.MarkFlagRequired("command-id")

	// fetch command
	rootCmd.AddCommand(fetchCmd)
	fetchCmd.Flags().StringVar(&flagInstance, "instance", "", "인스턴스 ID (파일명 필터용)")
	fetchCmd.Flags().StringVar(&flagBucket, "bucket", envOr("S3_BUCKET", ""), "(필수) S3 버킷명")
	fetchCmd.Flags().StringVar(&flagPrefix, "prefix", envOr("S3_PREFIX", "linux-vul/results"), "S3 키 프리픽스")
	fetchCmd.Flags().StringVar(&flagProfile, "profile", "ubuntu", "OS 프로파일")
	fetchCmd.Flags().StringVar(&flagFetchCheck, "check", "", "특정 체크 ID만 다운로드")
	fetchCmd.Flags().StringVar(&flagOutputDir, "output", "./fetched", "다운로드 저장 디렉터리")
	_ = fetchCmd.MarkFlagRequired("bucket")
}

// =============================================================================
// run command
// =============================================================================

var runCmd = &cobra.Command{
	Use:   "run",
	Short: "SSM RunCommand로 linux-vul 체크 실행",
}

// ─── run single ───────────────────────────────────────────────────────────────

var runSingleCmd = &cobra.Command{
	Use:   "single",
	Short: "단일 U-xx 체크 실행",
	RunE: func(cmd *cobra.Command, args []string) error {
		ctx := context.Background()

		debug.Section("run single")
		debug.F("instance=%s  check=%s  profile=%s  bucket=%s",
			flagInstance, flagCheckID, flagProfile, flagBucket)
		debug.F("repo=%s  timeout=%ds  no-wait=%v", flagRepoPath, flagTimeout, flagNoWait)

		debug.F("SSM 클라이언트 초기화 중...")
		clientStart := time.Now()
		client, err := ssm.NewClient(ctx, ssm.ClientConfig{
			Region:      flagRegion,
			EndpointURL: flagSSMEndpoint,
		})
		if err != nil {
			debug.F("SSM 클라이언트 초기화 실패: %v", err)
			return fmt.Errorf("SSM 클라이언트 초기화 실패: %w", err)
		}
		debug.F("SSM 클라이언트 초기화 완료: %dms", time.Since(clientStart).Milliseconds())

		req := ssm.RunSingleRequest{
			InstanceID: flagInstance,
			CheckID:    flagCheckID,
			Profile:    flagProfile,
			S3Bucket:   flagBucket,
			S3Prefix:   flagPrefix,
			RepoPath:   flagRepoPath,
			Timeout:    flagTimeout,
		}
		debug.F("RunSingleRequest: %+v", req)

		fmt.Printf("[ssm-runner] 단일 체크 실행: %s on %s (profile=%s)\n",
			flagCheckID, flagInstance, flagProfile)

		sendStart := time.Now()
		cmdID, err := client.RunSingle(ctx, req)
		if err != nil {
			debug.F("RunSingle 실패: %v (elapsed=%dms)", err, time.Since(sendStart).Milliseconds())
			return fmt.Errorf("SSM RunCommand 실패: %w", err)
		}
		debug.F("SendCommand 완료: commandId=%s  elapsed=%dms", cmdID, time.Since(sendStart).Milliseconds())
		fmt.Printf("[ssm-runner] Command ID: %s\n", cmdID)

		if flagNoWait {
			fmt.Println("[ssm-runner] --no-wait 모드: 결과 대기 건너뜀")
			debug.F("no-wait 종료")
			return nil
		}

		fmt.Println("[ssm-runner] 실행 완료 대기 중...")
		// executionTimeout=flagTimeout이므로 WaitTimeout에 pollInterval(5s)+버퍼(30s)를 더해
		// 스크립트가 timeout 직전에 완료된 경우에도 다음 poll에서 결과를 수신할 수 있도록 함
		waitTimeout := flagTimeout + 35
		debug.F("WaitForCommand 시작: commandId=%s execTimeout=%ds waitTimeout=%ds", cmdID, flagTimeout, waitTimeout)
		waitStart := time.Now()
		result, err := client.WaitForCommand(ctx, cmdID, flagInstance, waitTimeout)
		if err != nil {
			debug.F("WaitForCommand 실패: %v (elapsed=%dms)", err, time.Since(waitStart).Milliseconds())
			return fmt.Errorf("결과 대기 실패: %w", err)
		}
		debug.F("WaitForCommand 완료: status=%s exit=%d elapsed=%dms",
			result.Status, result.ExitCode, time.Since(waitStart).Milliseconds())

		printResult(result)
		return nil
	},
}

// ─── run full ─────────────────────────────────────────────────────────────────

var runFullCmd = &cobra.Command{
	Use:   "full",
	Short: "U-01~U-72 전체 감사 실행",
	RunE: func(cmd *cobra.Command, args []string) error {
		ctx := context.Background()

		debug.Section("run full")
		debug.F("instance=%s  profile=%s  bucket=%s  pipeline=%v  force=%v",
			flagInstance, flagProfile, flagBucket, flagRunPipeline, flagForce)
		debug.F("repo=%s  timeout=%ds  no-wait=%v", flagRepoPath, flagTimeout, flagNoWait)

		debug.F("SSM 클라이언트 초기화 중...")
		clientStart := time.Now()
		client, err := ssm.NewClient(ctx, ssm.ClientConfig{
			Region:      flagRegion,
			EndpointURL: flagSSMEndpoint,
		})
		if err != nil {
			debug.F("SSM 클라이언트 초기화 실패: %v", err)
			return fmt.Errorf("SSM 클라이언트 초기화 실패: %w", err)
		}
		debug.F("SSM 클라이언트 초기화 완료: %dms", time.Since(clientStart).Milliseconds())

		req := ssm.RunFullRequest{
			InstanceID:  flagInstance,
			Profile:     flagProfile,
			S3Bucket:    flagBucket,
			S3Prefix:    flagPrefix,
			RepoPath:    flagRepoPath,
			Timeout:     flagTimeout,
			RunPipeline: flagRunPipeline,
			Force:       flagForce,
		}
		debug.F("RunFullRequest: %+v", req)

		fmt.Printf("[ssm-runner] 전체 감사 실행: %s (profile=%s, pipeline=%v)\n",
			flagInstance, flagProfile, flagRunPipeline)

		sendStart := time.Now()
		cmdID, err := client.RunFull(ctx, req)
		if err != nil {
			debug.F("RunFull 실패: %v (elapsed=%dms)", err, time.Since(sendStart).Milliseconds())
			return fmt.Errorf("SSM RunCommand 실패: %w", err)
		}
		debug.F("SendCommand 완료: commandId=%s  elapsed=%dms", cmdID, time.Since(sendStart).Milliseconds())
		fmt.Printf("[ssm-runner] Command ID: %s\n", cmdID)

		if flagNoWait {
			fmt.Println("[ssm-runner] --no-wait 모드: 결과 대기 건너뜀")
			debug.F("no-wait 종료")
			return nil
		}

		fmt.Println("[ssm-runner] 전체 감사 완료 대기 중 (최대 2시간)...")
		waitTimeout := flagTimeout + 35
		debug.F("WaitForCommand 시작: commandId=%s execTimeout=%ds waitTimeout=%ds", cmdID, flagTimeout, waitTimeout)
		waitStart := time.Now()
		result, err := client.WaitForCommand(ctx, cmdID, flagInstance, waitTimeout)
		if err != nil {
			debug.F("WaitForCommand 실패: %v (elapsed=%dms)", err, time.Since(waitStart).Milliseconds())
			return fmt.Errorf("결과 대기 실패: %w", err)
		}
		debug.F("WaitForCommand 완료: status=%s exit=%d elapsed=%dms",
			result.Status, result.ExitCode, time.Since(waitStart).Milliseconds())

		printResult(result)
		return nil
	},
}

// =============================================================================
// status command
// =============================================================================

var statusCmd = &cobra.Command{
	Use:   "status",
	Short: "SSM Command 실행 상태 조회",
	RunE: func(cmd *cobra.Command, args []string) error {
		ctx := context.Background()

		debug.Section("status")
		debug.F("commandId=%s  instance=%q", flagCommandID, flagInstance)

		client, err := ssm.NewClient(ctx, ssm.ClientConfig{
			Region:      flagRegion,
			EndpointURL: flagSSMEndpoint,
		})
		if err != nil {
			return fmt.Errorf("SSM 클라이언트 초기화 실패: %w", err)
		}

		debug.F("ListCommandInvocations 호출 중...")
		queryStart := time.Now()
		invocations, err := client.GetCommandStatus(ctx, flagCommandID, flagInstance)
		if err != nil {
			debug.F("GetCommandStatus 실패: %v (elapsed=%dms)", err, time.Since(queryStart).Milliseconds())
			return fmt.Errorf("상태 조회 실패: %w", err)
		}
		debug.F("GetCommandStatus 완료: %d 개 invocation  elapsed=%dms",
			len(invocations), time.Since(queryStart).Milliseconds())

		for i, inv := range invocations {
			debug.F("invocation[%d]: instance=%s status=%s exit=%d outputLen=%d",
				i, inv.InstanceID, inv.Status, inv.ExitCode, len(inv.Output))
			fmt.Printf("Instance: %-22s  Status: %-12s  Exit: %d\n",
				inv.InstanceID, inv.Status, inv.ExitCode)
			if inv.Output != "" {
				fmt.Printf("  └── Output: %s\n", truncate(inv.Output, 200))
			}
		}
		return nil
	},
}

// =============================================================================
// fetch command
// =============================================================================

var fetchCmd = &cobra.Command{
	Use:   "fetch",
	Short: "S3에서 진단 결과 MD 파일 다운로드",
	RunE: func(cmd *cobra.Command, args []string) error {
		ctx := context.Background()

		debug.Section("fetch")
		debug.F("bucket=%s  prefix=%s  profile=%s  check=%q  instance=%q  output=%s",
			flagBucket, flagPrefix, flagProfile, flagFetchCheck, flagInstance, flagOutputDir)

		debug.F("S3 클라이언트 초기화 중...")
		clientStart := time.Now()
		s3client, err := s3util.NewClient(ctx, s3util.ClientConfig{
			Region:      flagRegion,
			EndpointURL: flagS3Endpoint,
		})
		if err != nil {
			debug.F("S3 클라이언트 초기화 실패: %v", err)
			return fmt.Errorf("S3 클라이언트 초기화 실패: %w", err)
		}
		debug.F("S3 클라이언트 초기화 완료: %dms", time.Since(clientStart).Milliseconds())

		req := s3util.FetchRequest{
			Bucket:     flagBucket,
			Prefix:     flagPrefix,
			Profile:    flagProfile,
			CheckID:    flagFetchCheck,
			InstanceID: flagInstance,
			OutputDir:  flagOutputDir,
		}
		debug.F("FetchRequest: %+v", req)

		fmt.Printf("[ssm-runner] S3 결과 다운로드: s3://%s/%s/%s/\n",
			flagBucket, flagPrefix, flagProfile)

		fetchStart := time.Now()
		downloaded, err := s3client.Fetch(ctx, req)
		if err != nil {
			debug.F("Fetch 실패: %v (elapsed=%dms)", err, time.Since(fetchStart).Milliseconds())
			return fmt.Errorf("S3 다운로드 실패: %w", err)
		}
		debug.F("Fetch 완료: %d 파일  elapsed=%dms", len(downloaded), time.Since(fetchStart).Milliseconds())

		fmt.Printf("[ssm-runner] 다운로드 완료: %d 개 파일 → %s\n", len(downloaded), flagOutputDir)
		for _, f := range downloaded {
			fmt.Printf("  ✓ %s\n", f)
		}
		return nil
	},
}

// =============================================================================
// 헬퍼
// =============================================================================

func printResult(r *ssm.CommandResult) {
	status := "✓ SUCCESS"
	if r.ExitCode != 0 {
		status = fmt.Sprintf("✗ FAILED (exit=%d)", r.ExitCode)
	}
	fmt.Printf("\n[ssm-runner] %s\n", status)
	if r.Output != "" {
		fmt.Println("─── Output ───────────────────────────────────────────────────")
		fmt.Println(r.Output)
		fmt.Println("──────────────────────────────────────────────────────────────")
	}
	debug.F("printResult: status=%s exit=%d outputLen=%d", r.Status, r.ExitCode, len(r.Output))
	if r.ExitCode != 0 {
		os.Exit(r.ExitCode)
	}
}

func truncate(s string, n int) string {
	if len(s) <= n {
		return s
	}
	return s[:n] + "..."
}

func envOr(key, fallback string) string {
	if v := os.Getenv(key); v != "" {
		return v
	}
	return fallback
}

// =============================================================================
// main
// =============================================================================

func main() {
	if err := rootCmd.Execute(); err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}
}

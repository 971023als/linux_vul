// internal/debug/debug.go
// 전역 디버그 로거 — --debug 플래그로 활성화
//
// 사용:
//   debug.Enable()           // main.go에서 --debug 파싱 후 호출
//   debug.F("msg %s", val)   // 어디서든 호출
//   debug.Section("SSM")     // ─── SSM ─── 구분선 출력

package debug

import (
	"fmt"
	"os"
	"sync"
	"time"
)

var (
	enabled bool
	mu      sync.RWMutex
)

// Enable 디버그 모드 활성화 (스레드 안전)
func Enable() {
	mu.Lock()
	defer mu.Unlock()
	enabled = true
}

// Enabled 현재 디버그 모드 여부 반환
func Enabled() bool {
	mu.RLock()
	defer mu.RUnlock()
	return enabled
}

// F 포맷 문자열로 디버그 메시지 출력
// 비활성화 상태에서는 아무것도 하지 않음 (오버헤드 없음)
func F(format string, args ...any) {
	if !Enabled() {
		return
	}
	ts := time.Now().Format("15:04:05.000")
	msg := fmt.Sprintf(format, args...)
	fmt.Fprintf(os.Stderr, "\033[35m[DBG %s]\033[0m %s\n", ts, msg)
}

// Section 구분선 + 섹션 이름 출력
func Section(name string) {
	if !Enabled() {
		return
	}
	ts := time.Now().Format("15:04:05.000")
	fmt.Fprintf(os.Stderr, "\033[35m[DBG %s]\033[0m ─── %s ───\n", ts, name)
}

// Elapsed 타이밍 측정 헬퍼
// 사용: defer debug.Elapsed("SSM SendCommand", time.Now())
func Elapsed(label string, start time.Time) {
	if !Enabled() {
		return
	}
	ms := time.Since(start).Milliseconds()
	F("%s 완료: %dms", label, ms)
}

// HTTPReq HTTP/API 요청 로그 (파라미터 요약)
func HTTPReq(service, action string, params map[string]string) {
	if !Enabled() {
		return
	}
	ts := time.Now().Format("15:04:05.000")
	fmt.Fprintf(os.Stderr, "\033[35m[DBG %s]\033[0m → %s.%s", ts, service, action)
	for k, v := range params {
		fmt.Fprintf(os.Stderr, "  %s=%s", k, v)
	}
	fmt.Fprintln(os.Stderr)
}

// HTTPResp HTTP/API 응답 로그
func HTTPResp(service, action string, statusCode int, elapsed time.Duration, extra string) {
	if !Enabled() {
		return
	}
	ts := time.Now().Format("15:04:05.000")
	icon := "✓"
	color := "\033[32m"
	if statusCode != 0 && statusCode >= 400 {
		icon = "✗"
		color = "\033[31m"
	}
	fmt.Fprintf(os.Stderr,
		"\033[35m[DBG %s]\033[0m %s%s\033[0m %s.%s  status=%d  elapsed=%dms  %s\n",
		ts, color, icon, service, action, statusCode, elapsed.Milliseconds(), extra,
	)
}

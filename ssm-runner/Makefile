# ssm-runner Makefile
#
# Docker 빌드: 프로젝트 루트에서 `docker build .` — go.sum은 빌드 내부에서 자동 생성됨.
# 로컬 빌드: 아래 타겟 사용.
#
# go.sum NOTE:
#   go.sum은 .dockerignore에 의해 Docker 빌드 컨텍스트에서 제외됩니다.
#   Dockerfile Stage 1에서 `go mod tidy`가 go.sum을 자동 생성합니다.
#   로컬 빌드 시에는 `make tidy` 또는 `make build`를 먼저 실행하세요.

BINARY   := ssm-runner
CMD_PATH := ./cmd/ssm-runner
LDFLAGS  := -ldflags="-s -w"

.PHONY: all tidy build clean test

all: tidy build

## tidy: go.sum 생성 / 의존성 정리 (로컬 첫 빌드 시 필수)
tidy:
	go mod tidy

## build: 현재 플랫폼용 바이너리 빌드 (tidy 포함)
build: tidy
	go build $(LDFLAGS) -o $(BINARY) $(CMD_PATH)

## build-linux: 내부망 배포용 정적 바이너리 (Linux amd64)
build-linux: tidy
	CGO_ENABLED=0 GOOS=linux GOARCH=amd64 \
	go build $(LDFLAGS) -o $(BINARY)-linux-amd64 $(CMD_PATH)

## test: 단위 테스트
test:
	go test ./...

## clean: 빌드 산출물 제거
clean:
	rm -f $(BINARY) $(BINARY)-linux-amd64

## help: 사용 가능한 타겟 목록 출력
help:
	@grep -E '^## ' Makefile | sed 's/^## /  make /'

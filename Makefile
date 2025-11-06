.PHONY: build test clean docker-build docker-up docker-down lint fmt help

# Default target
help:
	@echo "Available targets:"
	@echo "  build        - Build the Go application"
	@echo "  test         - Run tests"
	@echo "  lint         - Run linter (go vet)"
	@echo "  fmt          - Format Go code"
	@echo "  clean        - Clean build artifacts"
	@echo "  docker-build - Build Docker images"
	@echo "  docker-up    - Start services with docker-compose"
	@echo "  docker-down  - Stop services with docker-compose"

# Go application targets
build:
	cd login/gocode && go build -v main.go

test:
	cd login/gocode && go test -v ./...

lint:
	cd login/gocode && go vet ./...

fmt:
	cd login/gocode && go fmt ./...

clean:
	cd login/gocode && rm -f main
	docker-compose down 2>/dev/null || true
	docker system prune -f

# Docker targets
docker-build:
	docker-compose build

docker-up:
	docker-compose up -d

docker-down:
	docker-compose down

# CI targets (what GitHub Actions runs)
ci-test: lint test
	@cd login/gocode && if [ "$$(gofmt -s -l . | wc -l | tr -d ' ')" != "0" ]; then echo "Code not formatted properly"; gofmt -s -l .; exit 1; fi

# Development workflow
dev: fmt lint build test
	@echo "✅ All checks passed!"
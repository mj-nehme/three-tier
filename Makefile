.PHONY: build test clean docker-build k8s-deploy k8s-clean lint fmt help

# Default target
help:
	@echo "Available targets:"
	@echo "  build        - Build the Go application"
	@echo "  test         - Run tests"
	@echo "  lint         - Run linter (go vet)"
	@echo "  fmt          - Format Go code"
	@echo "  clean        - Clean build artifacts"
	@echo "  docker-build - Build Docker images"
	@echo "  k8s-deploy   - Deploy to Kubernetes"
	@echo "  k8s-clean    - Clean up Kubernetes deployment"

# Go application targets
build:
	cd login/gocode && go build -v main.go

test:
	cd login/gocode && go test -v ./...

test-coverage:
	cd login/gocode && go test -v -coverprofile=coverage.out ./...
	cd login/gocode && go tool cover -html=coverage.out -o coverage.html

lint:
	cd login/gocode && go vet ./...

fmt:
	cd login/gocode && go fmt ./...

clean:
	cd login/gocode && rm -f main coverage.out coverage.html
	make k8s-clean

# Docker targets
docker-build:
	docker build -t login-app ./login
	docker build -t mongo-app ./mongo

# Kubernetes targets
k8s-deploy: docker-build
	kubectl apply -f k8s/

k8s-clean:
	kubectl delete namespace three-tier-app --ignore-not-found=true

k8s-status:
	kubectl get all -n three-tier-app

# CI targets (what GitHub Actions runs)
ci-test: lint test
	@cd login/gocode && if [ "$$(gofmt -s -l . | wc -l | tr -d ' ')" != "0" ]; then echo "Code not formatted properly"; gofmt -s -l .; exit 1; fi

# Development workflow
dev: fmt lint build test
	@echo "✅ All checks passed!"
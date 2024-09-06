# This Makefile is meant to be used by people that do not usually work
# with Go source code. If you know what GOPATH is then you probably
# don't need to bother with make.

.PHONY: install clean build test docker-build-image docker-demo-operators docker-demo-initiator
.PHONY: docker-operator docker-initiator mockgen-install lint-prepare lint critic-prepare critic gosec-prepare gosec deadcode-prepare deadcode

GOBIN = ./build/bin
GO ?= latest
GORUN = env GO111MODULE=on go run
GOINSTALL = env GO111MODULE=on go install -v
GOTEST = env GO111MODULE=on go test -v
# Name of the Go binary output
BINARY_NAME=./bin/ssv-dkg
# Docker image name
DOCKER_IMAGE=ssv-dkg

DEFAULT_VERSION = "v2.1.0"
Version = $( shell git describe --tags $$(shell git rev-list --tags --max-count=1) 2>/dev/null || echo $(DEFAULT_VERSION))

install:
	$(GOINSTALL) -ldflags "-X main.Version=`git describe --tags $$(git rev-list --tags --max-count=1)`" cmd/ssv-dkg/ssv-dkg.go
	@echo "Done building."
	@echo "Run ssv-dkg to launch the tool."

clean:
	env GO111MODULE=on go clean -cache

# Recipe to compile the Go program
build_linux:
	@echo "Building Go binary..."
	GOOS=linux GOARCH=amd64 go build -o $(BINARY_NAME) -ldflags "-X main.Version=`git describe --tags $$(git rev-list --tags --max-count=1)`" ./cmd/ssv-dkg/ssv-dkg.go

build_windows:
	@echo "Building Go binary..."
	CGO_ENABLED=1 GOOS=windows GOARCH=amd64 go build -o $(BINARY_NAME).exe -ldflags "-X main.Version=`git describe --tags $$(git rev-list --tags --max-count=1)`" ./cmd/ssv-dkg/ssv-dkg.go

build_darwin: # MacOS
	@echo "Building Go binary..."
	CGO_ENABLED=1 GOOS=darwin GOARCH=arm64 go build -o $(BINARY_NAME)-darwin -ldflags "-X main.Version=v2.1.0" ./cmd/ssv-dkg/ssv-dkg.go 
build: build_linux build_windows build_darwin
 
# Recipe to run tests
test:
	@echo "running tests"
	go run gotest.tools/gotestsum@latest --format testname

# Recipe to build the Docker image
docker-build-image:
	@echo "Building Docker image..."
	DOCKER_BUILDKIT=1 docker build -t $(DOCKER_IMAGE) .

docker-demo-operators:
	@echo "Running operators in docker demo"
	docker-compose up --build operator1 operator2 operator3 operator4 operator5 operator6 operator7 operator8

docker-demo-initiator:
	@echo "Running initiator in docker demo"
	docker-compose up --build initiator

docker-demo-ping:
	@echo "Running ping operators in docker demo"
	docker-compose up --build ping

docker-operator:
	@echo "Running operator docker, make sure to update ./examples/operator1/congig/config.yaml"
	docker run \
	  --name svv-dkg-operator \
	  -p 3030:3030 \
	  -v $(shell pwd)/examples:/data \
	  $(DOCKER_IMAGE):latest \
	  start-operator --configPath /data/operator1/config

docker-initiator:
	@echo "Running initiator docker, make sure to update ./examples/initiator/config/init.yaml"
	docker run \
	  --name ssv-dkg-initiator \
	  -v $(shell pwd)/examples:/data \
	  $(DOCKER_IMAGE):latest \
	  init --configPath /data/initiator/config

docker-build-deposit-verify:
	DOCKER_BUILDKIT=1 docker build --progress=plain --no-cache -f $(shell pwd)/utils/deposit_verify/Dockerfile -t deposit-verify .

docker-deposit-verify:
	cp $(DEPOSIT_FILE_PATH) /tmp/deposit_data.json && \
	docker run --rm \
	  --name dkg-deposit-verify \
	  -v /tmp/deposit_data.json:/deposit-verify/utils/deposit_verify/deposit_data.json \
	  -v $(NETWORK_ENV_PATH):/deposit-verify/utils/deposit_verify/.env \
	  -e DEPOSIT_FILE_PATH=deposit_data.json \
	  deposit-verify:latest && \
	  rm /tmp/deposit_data.json

mockgen-install:
	go install github.com/golang/mock/mockgen@v1.6.0
	@which mockgen || echo "Error: ensure `go env GOPATH` is added to PATH"

lint-prepare:
	@echo "Preparing Linter"
	curl -sfL https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh| sh -s latest

lint:
	./bin/golangci-lint run -v ./...
	@if [ ! -z "${UNFORMATTED}" ]; then \
		echo "Some files requires formatting, please run 'go fmt ./...'"; \
		exit 1; \
	fi

critic-prepare:
	@echo "Preparing GoCritic"
	go install -v github.com/go-critic/go-critic/cmd/gocritic@latest

critic:
	gocritic check -enableAll ./...

deadcode-prepare:
	@echo "Preparing Deadcode"
	go install golang.org/x/tools/cmd/deadcode@latest

deadcode:
	deadcode -test ./...

gosec-prepare:
	@echo "Preparing Gosec"
	go install github.com/securego/gosec/v2/cmd/gosec@latest

gosec:
	gosec ./...


dkg_initiator:
	./bin/ssv-dkg-darwin init --validators 10 --operatorIDs 11,21,24,29 --operatorsInfoPath ./config/operators-holesky.json --owner 0x81592c3de184a3e2c0dcb5a261bc107bfa91f494 --nonce 4 --withdrawAddress 0xa1a66cc5d309f19fb2fda2b7601b223053d0f7f4 --network "holesky" --outputPath ./output --logLevel info --logFormat json --logLevelFormat capitalColor --logFilePath ./initiator_logs/debug.log

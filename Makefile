# VERSION defines the project version for the application and Helm Chart.
# Update this value when you upgrade the version of your project.
# To re-generate a bundle for another specific version without changing the standard setup, you can:
# - use the VERSION as arg of the bundle target (e.g make bundle VERSION=0.0.2)
# - use environment variables to overwrite this value (e.g export VERSION=0.0.2)
VERSION ?= 0.1.0

# IMAGE_TAG_BASE defines the image registry namespace and part of the image name for remote images.
# This variable is used to construct the app container image, and in the future the OCI Helm Chart.
IMAGE_TAG_BASE ?= quay.io/adambkaplan/sample-go-multiarch

# Use APP_TAG to use a different tag to build and push the application image.
# This defaults to semantic version of the project above.
APP_TAG ?= v$(VERSION)

# IMG sets the URL to build and push the application image.
IMG ?= $(IMAGE_TAG_BASE):$(APP_TAG)

# Get the currently used golang install path (in GOPATH/bin, unless GOBIN is set)
ifeq (,$(shell go env GOBIN))
GOBIN=$(shell go env GOPATH)/bin
else
GOBIN=$(shell go env GOBIN)
endif

# CONTAINER_TOOL defines the container tool to be used for building images.
# Be aware that the target commands are only tested with Docker which is
# scaffolded by default. However, you might want to replace it to use other
# tools. (i.e. podman)
CONTAINER_TOOL ?= podman

# Setting SHELL to bash allows bash commands to be executed by recipes.
# Options are set to exit when a recipe line exits non-zero or a piped command fails.
SHELL = /usr/bin/env bash -o pipefail
.SHELLFLAGS = -ec

.PHONY: all
all: build

##@ General

# The help target prints out all targets with their descriptions organized
# beneath their categories. The categories are represented by '##@' and the
# target descriptions by '##'. The awk command is responsible for reading the
# entire set of makefiles included in this invocation, looking for lines of the
# file as xyz: ## something, and then pretty-format the target and help. Then,
# if there's a line with ##@ something, that gets pretty-printed as a category.
# More info on the usage of ANSI control characters for terminal formatting:
# https://en.wikipedia.org/wiki/ANSI_escape_code#SGR_parameters
# More info on the awk command:
# http://linuxcommand.org/lc3_adv_awk.php

.PHONY: help
help: ## Display this help.
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} /^[a-zA-Z_0-9-]+:.*?##/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

##@ Development

.PHONY: fmt
fmt: ## Run go fmt against code.
	go fmt ./...

.PHONY: vet
vet: ## Run go vet against code.
	go vet ./...

.PHONY: tidy
tidy: ## Run go mod tidy against the code.
	go mod tidy

.PHONY: test
test: fmt vet ## Run tests.
	go test ./... -coverprofile cover.out

GOLANGCI_LINT = $(shell pwd)/bin/golangci-lint
GOLANGCI_LINT_VERSION ?= v1.57.2
golangci-lint:
	@[ -f $(GOLANGCI_LINT) ] || { \
	set -e ;\
	curl -sSfL https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh | sh -s -- -b $(shell dirname $(GOLANGCI_LINT)) $(GOLANGCI_LINT_VERSION) ;\
	}

.PHONY: lint
lint: golangci-lint ## Run golangci-lint linter & yamllint
	$(GOLANGCI_LINT) run

.PHONY: lint-fix
lint-fix: golangci-lint ## Run golangci-lint linter and perform fixes
	$(GOLANGCI_LINT) run --fix

##@ Build


# PLATFORMS defines the target platforms for the application image.
# Pass as a comma-separated list of GOOS/GOARCH values (e.g. linux/amd64,linux/arm64).
# Building for a non-native compute archtiecture may incur siginficant performance penalties due to
# the use of CPU emulation.
PLATFORMS ?= $(shell go env GOOS)/$(shell go env GOARCH)

KO_FLAGS ?= --bare --tags $(APP_TAG) --platform $(PLATFORMS)

.PHONY: build
build: fmt vet ## Build the application binary.
	go build -o _output/bin/server cmd/main.go

.PHONY: run
run: ## Run the server locally.
	go run ./cmd/main.go

.PHONY: ko-build
ko-build: ## Build and push the application image using ko.
	KO_DOCKER_REPO=${IMAGE_TAG_BASE} ko build $(KO_FLAGS) ./cmd

# If you wish to build the manager image targeting other platforms you can use the --platform flag.
# (i.e. docker build --platform linux/arm64). However, you must enable docker buildKit for it.
# More info: https://docs.docker.com/develop/develop-images/build_enhancements/
.PHONY: docker-build
docker-build: ## Build docker image with the manager.
	$(CONTAINER_TOOL) build --platform=$(PLATFORMS) -t ${IMG} .
	$(CONTAINER_TOOL) push ${IMG}

##@ Deployment

ifndef ignore-not-found
  ignore-not-found = false
endif

HELM_VALUES ?= helm/values/values-latest-crc.yaml

.PHONY: install
install: ## Deploy the application to the K8s cluster specified in ~/.kube/config using Helm.
	helm upgrade sample-go-multiarch helm/sample-go-multiarch --install --values ${HELM_VALUES} --set image.fullRef=${IMG}

.PHONY: uninstall
uninstall: ## Uninstall the application from the cluster. Call with ignore-not-found=true to ignore resource not found errors during deletion.
	helm uninstall sample-go-multiarch --ignore-not-found=${ignore-not-found}

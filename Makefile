
LOCAL_BIN:=$(CURDIR)/bin
GOLANGCI_BIN:=$(LOCAL_BIN)/golangci-lint
GOLANGCI_TAG:=1.21.0

# install golangci-lint binary
.PHONY: install-lint
install-lint:
ifeq ($(wildcard $(GOLANGCI_BIN)),)
	$(info "Downloading golangci-lint v$(GOLANGCI_TAG"))
	tmp=$$(mktemp -d) && cd $$tmp && pwd && go mod init temp && go get -d github.com/golangci/golangci-lint@v$(GOLANGCI_TAG) && \
		go build -ldflags "-X 'main.version=$(GOLANGCI_TAG)' -X 'main.commit=test' -X 'main.date=test'" -o $(LOCAL_BIN)/golangci-lint github.com/golangci/golangci-lint/cmd/golangci-lint && \
		rm -rf $$tmp
GOLANGCI_BIN:=$(LOCAL_BIN)/golangci-lint
endif

.PHONY: .lint
.lint: install-lint
	$(info #Running lint...)
	$(GOLANGCI_BIN) run --new-from-rev=origin/master --config=.golangci.pipeline.yaml ./...

.PHONY: lint
lint: .lint

.PHONY: .lint-full
.lint-full: install-lint
	$(GOLANGCI_BIN) run --config=.golangci.pipeline.yaml ./...

.PHONY: lint-full
lint-full: .lint-full

.PHONY: test
test:
	$(info #Running tests...)
	go test ./...

.PHONY: goimports
goimports:
	$(info #Running goimports...)
	find . -name "*.go" | grep -vE "vendor|_mock.go" | xargs -n1 goimports -w
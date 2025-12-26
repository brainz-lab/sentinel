.PHONY: build build-all clean install test

VERSION := 1.0.0
BINARY := sentinel-agent
LDFLAGS := -ldflags "-s -w -X sentinel-agent/config.AgentVersion=$(VERSION)"

# Build for current platform
build:
	go build $(LDFLAGS) -o $(BINARY) .

# Build for all platforms
build-all: clean
	mkdir -p dist
	GOOS=linux GOARCH=amd64 go build $(LDFLAGS) -o dist/$(BINARY)-linux-amd64 .
	GOOS=linux GOARCH=arm64 go build $(LDFLAGS) -o dist/$(BINARY)-linux-arm64 .
	GOOS=darwin GOARCH=amd64 go build $(LDFLAGS) -o dist/$(BINARY)-darwin-amd64 .
	GOOS=darwin GOARCH=arm64 go build $(LDFLAGS) -o dist/$(BINARY)-darwin-arm64 .

# Clean build artifacts
clean:
	rm -f $(BINARY)
	rm -rf dist/

# Install locally
install: build
	sudo cp $(BINARY) /usr/local/bin/
	sudo chmod +x /usr/local/bin/$(BINARY)

# Run tests
test:
	go test ./...

# Run the agent locally
run: build
	./$(BINARY) -config agent.example.yml

# Format code
fmt:
	go fmt ./...

# Lint code
lint:
	golangci-lint run

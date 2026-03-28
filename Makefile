.PHONY: build
build:
	mkdir -p dist
	go build -o dist/remote-chrome-mcp cmd/main.go

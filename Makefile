.PHONY: build image

build:
	mkdir -p dist
	go build -o dist/remote-chrome-mcp cmd/main.go

image:
	docker build -t remote-chrome-mcp .

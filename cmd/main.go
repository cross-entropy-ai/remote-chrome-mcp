package main

import (
	"log"
	"net/http"
	"net/http/httputil"
	"net/url"
	"os"
	"strings"
)

func main() {
	token := os.Getenv("AUTH_TOKEN")
	if token == "" {
		log.Fatal("AUTH_TOKEN environment variable is required")
	}

	listenAddr := os.Getenv("LISTEN_ADDR")
	if listenAddr == "" {
		listenAddr = ":8080"
	}

	mcpTarget, _ := url.Parse("http://127.0.0.1:3000")
	vncTarget, _ := url.Parse("http://127.0.0.1:6080")

	mcpProxy := newFlushingProxy(mcpTarget)
	vncProxy := newFlushingProxy(vncTarget)

	mux := http.NewServeMux()

	// /vnc/ → noVNC, no auth
	mux.HandleFunc("/vnc/", func(w http.ResponseWriter, r *http.Request) {
		r.URL.Path = strings.TrimPrefix(r.URL.Path, "/vnc")
		if r.URL.Path == "" {
			r.URL.Path = "/"
		}
		vncProxy.ServeHTTP(w, r)
	})

	// /websockify → noVNC websocket, no auth
	mux.HandleFunc("/websockify", func(w http.ResponseWriter, r *http.Request) {
		vncProxy.ServeHTTP(w, r)
	})

	// everything else → mcp-proxy, requires token
	mux.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		if r.URL.Query().Get("token") != token {
			http.Error(w, "unauthorized", http.StatusUnauthorized)
			return
		}
		mcpProxy.ServeHTTP(w, r)
	})

	log.Printf("listening on %s", listenAddr)
	log.Fatal(http.ListenAndServe(listenAddr, mux))
}

func newFlushingProxy(target *url.URL) *httputil.ReverseProxy {
	proxy := httputil.NewSingleHostReverseProxy(target)
	proxy.FlushInterval = -1 // flush immediately for SSE
	return proxy
}

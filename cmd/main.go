package main

import (
	"log"
	"net/http"
	"net/http/httputil"
	"net/url"
	"os"
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
	mcpProxy := httputil.NewSingleHostReverseProxy(mcpTarget)
	mcpProxy.FlushInterval = -1

	handler := func(w http.ResponseWriter, r *http.Request) {
		if r.URL.Query().Get("token") != token {
			http.Error(w, "Unauthorized", http.StatusUnauthorized)
			return
		}
		mcpProxy.ServeHTTP(w, r)
	}

	log.Printf("listening on %s", listenAddr)
	log.Fatal(http.ListenAndServe(listenAddr, http.HandlerFunc(handler)))
}

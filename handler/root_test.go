package handler

import (
	"io"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"
)

func TestEmbedFS(t *testing.T) {
	indexFile, err := htmlTemplates.ReadFile("web/index.html")
	if err != nil {
		t.Errorf("expected to read %q, got error: %v", "index.html", err)
	}
	if len(indexFile) == 0 {
		t.Errorf("expected non-empty file for %q", "index.html")
	}
}

func TestRootHandler(t *testing.T) {
	handler := MustRootHandler()
	testServer := httptest.NewServer(handler)
	defer testServer.Close()

	resp, err := http.Get(testServer.URL)
	if err != nil {
		t.Errorf("unexpected response error: %v", err)
	}
	if resp.StatusCode != http.StatusOK {
		t.Errorf("expected response code 200, got %d", resp.StatusCode)
	}
	body, err := io.ReadAll(resp.Body)
	resp.Body.Close()
	if err != nil {
		t.Errorf("unexpected error reading response: %v", err)
	}
	if !strings.Contains(string(body), "Namespace: demo-ns") {
		t.Errorf("expected page to contain string %q, got \n%s", "Namespace: demo-ns", string(body))
	}
}

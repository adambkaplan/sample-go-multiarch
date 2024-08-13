package handler

import (
	"embed"
	"html/template"
	"log"
	"net/http"
	"runtime"
)

//go:embed web/*
var htmlTemplates embed.FS

type RootHandler struct {
	Namespace string
	Pod       string
	OS        string
	Arch      string
	templates *template.Template
}

func MustRootHandler() *RootHandler {
	handler := &RootHandler{
		Namespace: "demo-ns",
		Pod:       "demo-pod",
		OS:        runtime.GOOS,
		Arch:      runtime.GOARCH,
	}
	handler.templates = template.Must(template.ParseFS(htmlTemplates, "web/*"))
	return handler
}

func (h *RootHandler) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	log.Printf("Received request at %q", "/")
	if err := h.templates.ExecuteTemplate(w, "index.html", h); err != nil {
		log.Printf("error rendering response: %v\n", err)
		w.Write([]byte("Internal server error"))
		w.WriteHeader(http.StatusInternalServerError)
	}
}

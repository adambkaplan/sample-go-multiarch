package handler

import (
	"embed"
	"html/template"
	"log"
	"net/http"
	"os"
	"runtime"
)

//go:embed web/*
var htmlTemplates embed.FS

type PodInfo struct {
	Namespace string
	Name      string
	NodeName  string
	IPAddress string
}

func PodInfoFromEnv() *PodInfo {
	return &PodInfo{
		Namespace: os.Getenv("POD_NAMESPACE"),
		Name:      os.Getenv("POD_NAME"),
		NodeName:  os.Getenv("NODE_NAME"),
		IPAddress: os.Getenv("POD_IP"),
	}
}

type RootHandler struct {
	*PodInfo
	OS        string
	Arch      string
	templates *template.Template
}

func MustRootHandler(pod *PodInfo) *RootHandler {
	handler := &RootHandler{
		PodInfo: pod,
		OS:      runtime.GOOS,
		Arch:    runtime.GOARCH,
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

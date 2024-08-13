package main

import (
	"context"
	"errors"
	"log"
	"net/http"
	"time"

	"github.com/adambkaplan/sample-go-multiarch/internal/handler"
	"sigs.k8s.io/controller-runtime/pkg/manager/signals"
)

func main() {
	mainCtx := signals.SetupSignalHandler()
	rootHandler := handler.MustRootHandler()

	server := &http.Server{
		Addr: ":8080",
	}
	http.Handle("/", rootHandler)

	log.Printf("Listening and serving at %s\n", server.Addr)
	go func() {
		if err := server.ListenAndServe(); !errors.Is(http.ErrServerClosed, err) {
			log.Fatalf("HTTP server error: %v\n", err)
		}
		log.Println("Stopped serving new connections.")
	}()

	<-mainCtx.Done()

	log.Println("Shutting down server.")
	shutdownCtx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()
	server.Shutdown(shutdownCtx)
	log.Println("Stopped HTTP server.")
}

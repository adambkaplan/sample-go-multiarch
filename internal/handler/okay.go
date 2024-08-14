package handler

import (
	"encoding/json"
	"log"
	"net/http"
)

type okResponse struct {
	Alive bool `json:"alive"`
	Ready bool `json:"ready"`
}

func okay() okResponse {
	return okResponse{
		Alive: true,
		Ready: true,
	}
}

func OKHandler(w http.ResponseWriter, r *http.Request) {
	log.Printf("Received request at %q", "/healthz")
	jsonW := json.NewEncoder(w)
	err := jsonW.Encode(okay())
	if err != nil {
		w.WriteHeader(http.StatusInternalServerError)
	}
}

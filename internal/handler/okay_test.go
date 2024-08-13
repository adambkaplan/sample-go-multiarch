package handler

import (
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"testing"
)

func TestOKHandler(t *testing.T) {
	testServer := httptest.NewServer(http.HandlerFunc(OKHandler))
	defer testServer.Close()

	resp, err := http.Get(testServer.URL)
	if err != nil {
		t.Errorf("unexpected response error: %v", err)
	}
	if resp.StatusCode != http.StatusOK {
		t.Errorf("expected response code 200, got %d", resp.StatusCode)
	}

	jsonDecoder := json.NewDecoder(resp.Body)
	respData := &okResponse{}
	err = jsonDecoder.Decode(respData)
	resp.Body.Close()
	if err != nil {
		t.Errorf("unexpected error reading response: %v", err)
	}
	if !respData.Alive {
		t.Errorf("expected Alive to be true, got false")
	}
	if !respData.Ready {
		t.Errorf("expected Ready to be true, got false")
	}

}

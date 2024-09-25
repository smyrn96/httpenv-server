package main

import (
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"os"
	"strings"
	"testing"
)

import "testing"

func TestServe(t *testing.T) {
	// Set up environment variables for testing
	os.Setenv("TEST_ENV_VAR", "test_value")
	defer os.Unsetenv("TEST_ENV_VAR") // Clean up after the test

	// Create a new HTTP request (GET request)
	req, err := http.NewRequest("GET", "/", nil)
	if err != nil {
		t.Fatalf("could not create request: %v", err)
	}

	// Create a ResponseRecorder to record the response
	rr := httptest.NewRecorder()

	// Call the serve function with the request and ResponseRecorder
	serve(rr, req)

	// Check the status code is 200 (OK)
	if rr.Code != http.StatusOK {
		t.Errorf("expected status 200 OK, got %d", rr.Code)
	}

	// Parse the response body
	var result map[string]string
	err = json.Unmarshal(rr.Body.Bytes(), &result)
	if err != nil {
		t.Fatalf("could not parse response body: %v", err)
	}

	// Check that the TEST_ENV_VAR environment variable is included in the response
	if val, ok := result["TEST_ENV_VAR"]; !ok || val != "test_value" {
		t.Errorf("expected TEST_ENV_VAR to be 'test_value', got '%s'", val)
	}

	// Optional: Check other environment variables if necessary
	for _, keyval := range os.Environ() {
		keyval := strings.SplitN(keyval, "=", 2)
		if val, ok := result[keyval[0]]; !ok || val != keyval[1] {
			t.Errorf("expected environment variable %s to have value %s", keyval[0], keyval[1])
		}
	}
}

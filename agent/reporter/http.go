package reporter

import (
	"bytes"
	"compress/gzip"
	"encoding/json"
	"fmt"
	"net/http"
	"time"

	"sentinel-agent/collector"
)

type HTTPReporter struct {
	endpoint string
	apiKey   string
	agentID  string
	client   *http.Client
}

func NewHTTPReporter(endpoint, apiKey, agentID string) *HTTPReporter {
	return &HTTPReporter{
		endpoint: endpoint,
		apiKey:   apiKey,
		agentID:  agentID,
		client: &http.Client{
			Timeout: 10 * time.Second,
		},
	}
}

func (r *HTTPReporter) Send(payload collector.Payload) error {
	data, err := json.Marshal(payload)
	if err != nil {
		return err
	}

	// Compress if payload is large
	var body bytes.Buffer
	useGzip := len(data) > 1024

	if useGzip {
		gz := gzip.NewWriter(&body)
		if _, err := gz.Write(data); err != nil {
			return err
		}
		gz.Close()
	} else {
		body.Write(data)
	}

	req, err := http.NewRequest("POST", r.endpoint+"/internal/agent", &body)
	if err != nil {
		return err
	}

	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("Authorization", "Bearer "+r.apiKey)
	req.Header.Set("X-Agent-ID", r.agentID)
	if useGzip {
		req.Header.Set("Content-Encoding", "gzip")
	}

	resp, err := r.client.Do(req)
	if err != nil {
		return err
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		return fmt.Errorf("unexpected status: %d", resp.StatusCode)
	}

	return nil
}

func (r *HTTPReporter) Register(payload map[string]interface{}) error {
	data, err := json.Marshal(payload)
	if err != nil {
		return err
	}

	req, err := http.NewRequest("POST", r.endpoint+"/internal/agent/register", bytes.NewBuffer(data))
	if err != nil {
		return err
	}

	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("Authorization", "Bearer "+r.apiKey)
	req.Header.Set("X-Agent-ID", r.agentID)

	resp, err := r.client.Do(req)
	if err != nil {
		return err
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		return fmt.Errorf("unexpected status: %d", resp.StatusCode)
	}

	return nil
}

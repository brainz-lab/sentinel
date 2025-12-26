package main

import (
	"flag"
	"log"
	"os"
	"os/signal"
	"syscall"
	"time"

	"sentinel-agent/collector"
	"sentinel-agent/config"
	"sentinel-agent/reporter"
)

func main() {
	configPath := flag.String("config", "/etc/sentinel/agent.yml", "Config file path")
	flag.Parse()

	cfg, err := config.Load(*configPath)
	if err != nil {
		log.Fatalf("Failed to load config: %v", err)
	}

	log.Printf("Starting Sentinel Agent v%s", cfg.AgentVersion)
	log.Printf("Agent ID: %s", cfg.AgentID)
	log.Printf("Endpoint: %s", cfg.Endpoint)
	log.Printf("Collection interval: %ds", cfg.Interval)

	agent := NewAgent(cfg)

	// Handle graceful shutdown
	sigChan := make(chan os.Signal, 1)
	signal.Notify(sigChan, syscall.SIGINT, syscall.SIGTERM)

	go agent.Run()

	<-sigChan
	log.Println("Shutting down agent...")
	agent.Stop()
}

type Agent struct {
	config   *config.Config
	reporter *reporter.HTTPReporter
	ticker   *time.Ticker
	done     chan bool
}

func NewAgent(cfg *config.Config) *Agent {
	return &Agent{
		config:   cfg,
		reporter: reporter.NewHTTPReporter(cfg.Endpoint, cfg.APIKey, cfg.AgentID),
		done:     make(chan bool),
	}
}

func (a *Agent) Run() {
	// Register agent on startup
	if err := a.register(); err != nil {
		log.Printf("Warning: Failed to register agent: %v", err)
	}

	a.ticker = time.NewTicker(time.Duration(a.config.Interval) * time.Second)

	// Collect and send immediately
	a.collectAndSend()

	for {
		select {
		case <-a.ticker.C:
			a.collectAndSend()
		case <-a.done:
			return
		}
	}
}

func (a *Agent) Stop() {
	if a.ticker != nil {
		a.ticker.Stop()
	}
	a.done <- true
}

func (a *Agent) register() error {
	sysInfo := collector.CollectSystemInfo()

	payload := map[string]interface{}{
		"agent_id":      a.config.AgentID,
		"hostname":      a.config.Hostname,
		"agent_version": a.config.AgentVersion,
		"system_info":   sysInfo,
	}

	return a.reporter.Register(payload)
}

func (a *Agent) collectAndSend() {
	payload := collector.Payload{
		AgentID:   a.config.AgentID,
		Hostname:  a.config.Hostname,
		Timestamp: time.Now().UTC(),
	}

	// Collect system metrics
	payload.System = collector.CollectSystem()

	// Collect disk metrics
	payload.Disks = collector.CollectDisks(a.config.ExcludedMounts)

	// Collect network metrics
	payload.Network = collector.CollectNetwork(a.config.ExcludedInterfaces)

	// Collect top processes
	payload.Processes = collector.CollectProcesses(a.config.TopProcesses)

	// Collect container metrics if enabled
	if a.config.CollectContainers {
		payload.Containers = collector.CollectContainers()
	}

	// Send to Sentinel API
	if err := a.reporter.Send(payload); err != nil {
		log.Printf("Failed to send metrics: %v", err)
	} else {
		log.Printf("Metrics sent successfully")
	}
}

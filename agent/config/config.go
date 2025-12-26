package config

import (
	"os"

	"gopkg.in/yaml.v3"
)

const AgentVersion = "1.0.0"

type Config struct {
	AgentID            string   `yaml:"agent_id"`
	Hostname           string   `yaml:"hostname"`
	Endpoint           string   `yaml:"endpoint"`
	APIKey             string   `yaml:"api_key"`
	Interval           int      `yaml:"interval"`
	TopProcesses       int      `yaml:"top_processes"`
	CollectContainers  bool     `yaml:"collect_containers"`
	ExcludedMounts     []string `yaml:"excluded_mounts"`
	ExcludedInterfaces []string `yaml:"excluded_interfaces"`
	AgentVersion       string   `yaml:"-"`
}

func Load(path string) (*Config, error) {
	data, err := os.ReadFile(path)
	if err != nil {
		return nil, err
	}

	cfg := &Config{
		Interval:           30,
		TopProcesses:       20,
		CollectContainers:  true,
		ExcludedMounts:     []string{"/dev", "/sys", "/proc", "/run"},
		ExcludedInterfaces: []string{"lo"},
	}

	if err := yaml.Unmarshal(data, cfg); err != nil {
		return nil, err
	}

	// Set hostname if not configured
	if cfg.Hostname == "" {
		hostname, _ := os.Hostname()
		cfg.Hostname = hostname
	}

	// Set agent version
	cfg.AgentVersion = AgentVersion

	return cfg, nil
}

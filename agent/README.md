# Sentinel Agent

Lightweight Go agent for collecting host and container metrics.

## Building

```bash
# Build for current platform
make build

# Build for all platforms
make build-all

# Install locally
make install
```

## Configuration

Create `/etc/sentinel/agent.yml`:

```yaml
agent_id: "my-server-001"
hostname: "my-server"
endpoint: "https://sentinel.brainzlab.ai"
api_key: "your_api_key"
interval: 30
top_processes: 20
collect_containers: true
excluded_mounts:
  - /dev
  - /sys
  - /proc
excluded_interfaces:
  - lo
```

## Running

```bash
# Run with config file
./sentinel-agent -config /etc/sentinel/agent.yml

# Run as a service (systemd)
sudo systemctl start sentinel-agent
```

## Metrics Collected

- **System**: CPU usage, load averages, memory, swap
- **Disk**: Usage per mount, I/O stats
- **Network**: Bytes/packets per interface, TCP connections
- **Processes**: Top N by CPU, memory usage
- **Containers**: Docker stats (CPU, memory, network, I/O)

## Installation Script

```bash
curl -sSL https://sentinel.brainzlab.ai/install.sh | sudo bash -s YOUR_API_KEY
```

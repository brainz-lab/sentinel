# Sentinel

Host and infrastructure monitoring for servers and containers.

[![CI](https://github.com/brainz-lab/sentinel/actions/workflows/ci.yml/badge.svg)](https://github.com/brainz-lab/sentinel/actions/workflows/ci.yml)
[![CodeQL](https://github.com/brainz-lab/sentinel/actions/workflows/codeql.yml/badge.svg)](https://github.com/brainz-lab/sentinel/actions/workflows/codeql.yml)
[![codecov](https://codecov.io/gh/brainz-lab/sentinel/graph/badge.svg)](https://codecov.io/gh/brainz-lab/sentinel)
[![License: OSAaSy](https://img.shields.io/badge/License-OSAaSy-blue.svg)](LICENSE)
[![Ruby](https://img.shields.io/badge/Ruby-3.2+-red.svg)](https://www.ruby-lang.org)

## Quick Start

```bash
# Install agent on your server
curl -fsSL https://get.brainzlab.ai/sentinel | bash

# View hosts in dashboard
open https://sentinel.brainzlab.ai/dashboard
```

## Installation

### With Docker

```bash
docker pull brainzllc/sentinel:latest

docker run -d \
  -p 3000:3000 \
  -e DATABASE_URL=postgres://user:pass@host:5432/sentinel \
  -e REDIS_URL=redis://host:6379/7 \
  -e RAILS_MASTER_KEY=your-master-key \
  brainzllc/sentinel:latest
```

### Local Development

```bash
bin/setup
bin/rails server
```

### Agent Installation

Install the lightweight Go agent on each host:

```bash
curl -fsSL https://get.brainzlab.ai/sentinel | bash
# or
wget -qO- https://get.brainzlab.ai/sentinel | bash
```

## Configuration

| Variable | Description | Required |
|----------|-------------|----------|
| `DATABASE_URL` | PostgreSQL connection | Yes |
| `REDIS_URL` | Redis for real-time stats | Yes |
| `RAILS_MASTER_KEY` | Rails credentials | Yes |
| `BRAINZLAB_PLATFORM_URL` | Platform URL for auth | Yes |

### Tech Stack

- **Backend**: Rails 8 API + Dashboard
- **Agent**: Go binary (~10MB, minimal overhead)
- **Database**: PostgreSQL 16 with TimescaleDB
- **Cache**: Redis 7 (real-time stats, heartbeats)
- **Frontend**: Hotwire (Turbo + Stimulus) / **Tailwind CSS**

## Usage

### Metrics Collected

| Category | Metrics |
|----------|---------|
| **CPU** | Usage %, load average, per-core |
| **Memory** | Used, available, swap, cache |
| **Disk** | Space, I/O read/write per mount |
| **Network** | Bandwidth in/out, packets |
| **Processes** | Top processes by CPU/memory |
| **Containers** | Docker stats per container |

### Agent Features

- ~10MB binary, minimal CPU/memory overhead
- Collects metrics every 10 seconds
- Auto-registers on first run
- Automatic reconnection
- Secure TLS communication

### Alerting

Set thresholds for:
- CPU usage > 90%
- Memory usage > 85%
- Disk usage > 90%
- Load average > CPU count
- Process memory leak detection

## API Reference

### Hosts
- `GET /api/v1/hosts` - List hosts
- `GET /api/v1/hosts/:id` - Host details
- `GET /api/v1/hosts/:id/metrics` - Host metrics
- `GET /api/v1/hosts/:id/processes` - Process list

### Containers
- `GET /api/v1/containers` - List containers
- `GET /api/v1/containers/:id/metrics` - Container metrics

### Agent
- `POST /internal/agent/report` - Agent metric submission

### MCP Tools

| Tool | Description |
|------|-------------|
| `sentinel_hosts` | List all hosts with status |
| `sentinel_metrics` | Get metrics for a host |
| `sentinel_processes` | List top processes |
| `sentinel_containers` | List containers |
| `sentinel_alerts` | List host alerts |

Full documentation: [docs.brainzlab.ai/products/sentinel](https://docs.brainzlab.ai/products/sentinel/overview)

## Self-Hosting

### Docker Compose

```yaml
services:
  sentinel:
    image: brainzllc/sentinel:latest
    ports:
      - "3000:3000"
    environment:
      DATABASE_URL: postgres://user:pass@db:5432/sentinel
      REDIS_URL: redis://redis:6379/7
      RAILS_MASTER_KEY: ${RAILS_MASTER_KEY}
      BRAINZLAB_PLATFORM_URL: http://platform:3000
    depends_on:
      - db
      - redis
```

### Testing

```bash
bin/rails test
bin/rubocop
```

## Contributing

See [CONTRIBUTING.md](../CONTRIBUTING.md) for development setup and contribution guidelines.

## License

This project is licensed under the [OSAaSy License](LICENSE).

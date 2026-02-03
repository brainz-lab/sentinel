# CLAUDE.md

> **Secrets Reference**: See `../.secrets.md` (gitignored) for master keys, server access, and MCP tokens.

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project: Sentinel by Brainz Lab

Host and infrastructure monitoring for servers, containers, and services.

**Domain**: sentinel.brainzlab.ai

**Tagline**: "Guardian of your servers"

**Status**: Not yet implemented - see sentinel-claude-code-prompt.md for full specification

## Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                        SENTINEL (Rails 8)                        │
│                                                                  │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐           │
│  │  Dashboard   │  │     API      │  │  MCP Server  │           │
│  │  (Hotwire)   │  │  (JSON API)  │  │   (Ruby)     │           │
│  │ /dashboard/* │  │  /api/v1/*   │  │   /mcp/*     │           │
│  └──────────────┘  └──────────────┘  └──────────────┘           │
│                           │                  │                   │
│                           ▼                  ▼                   │
│              ┌─────────────────────────────────────┐            │
│              │   PostgreSQL + TimescaleDB + Redis  │            │
│              └─────────────────────────────────────┘            │
└─────────────────────────────────────────────────────────────────┘
        ▲
        │ Metrics
┌───────┴───────┐
│  Go Agent     │
│  (on hosts)   │
└───────────────┘
```

## Tech Stack

- **Backend**: Rails 8 API + Dashboard
- **Frontend**: Hotwire (Turbo + Stimulus), Tailwind CSS
- **Database**: PostgreSQL with TimescaleDB
- **Cache**: Redis (real-time stats, heartbeats)
- **Agent**: Go binary (lightweight collector)
- **Real-time**: ActionCable (live dashboard)

## Key Models

- **Host**: Server/VM registration
- **HostMetric**: CPU, memory, load metrics
- **DiskMetric**: Disk space, I/O per mount
- **NetworkMetric**: Bandwidth, packets
- **ProcessSnapshot**: Running processes
- **Container**: Docker container metadata
- **ContainerMetric**: Container resource usage
- **AlertThreshold**: Host-level alert rules

## Metrics Collected

| Category | Metrics |
|----------|---------|
| **CPU** | Usage %, load average, per-core |
| **Memory** | Used, available, swap, cache |
| **Disk** | Space, I/O read/write per mount |
| **Network** | Bandwidth in/out, packets |
| **Processes** | Top processes by CPU/memory |
| **Containers** | Docker stats per container |

## Go Agent

Lightweight agent installed on each host:
- ~10MB binary, minimal overhead
- Collects metrics every 10s
- Reports to Sentinel API
- Auto-registers on first run

## MCP Tools

| Tool | Description |
|------|-------------|
| `sentinel_hosts` | List all hosts with status |
| `sentinel_metrics` | Get metrics for a host |
| `sentinel_processes` | List top processes |
| `sentinel_containers` | List containers |
| `sentinel_alerts` | List host alerts |

## API Endpoints

- `GET /api/v1/hosts` - List hosts
- `GET /api/v1/hosts/:id` - Host details
- `GET /api/v1/hosts/:id/metrics` - Host metrics
- `GET /api/v1/hosts/:id/processes` - Process list
- `GET /api/v1/containers` - List containers
- `POST /internal/agent/report` - Agent metric submission

Authentication: `Authorization: Bearer <key>` or `X-API-Key: <key>`

## Kamal Production Access

**IMPORTANT**: When using `kamal app exec --reuse`, docker exec doesn't inherit container environment variables. You must pass `SECRET_KEY_BASE` explicitly.

```bash
# Navigate to this service directory
cd /Users/afmp/brainz/brainzlab/sentinel

# Get the master key (used as SECRET_KEY_BASE)
cat config/master.key

# Run Rails console commands
kamal app exec -p --reuse -e SECRET_KEY_BASE:<master_key> 'bin/rails runner "<ruby_code>"'

# Example: Count hosts
kamal app exec -p --reuse -e SECRET_KEY_BASE:<master_key> 'bin/rails runner "puts Host.count"'
```

### Running Complex Scripts

For multi-line Ruby scripts, create a local file, scp to server, docker cp into container, then run with rails runner. See main brainzlab/CLAUDE.md for details.

### Other Kamal Commands

```bash
kamal deploy              # Deploy
kamal app logs -f         # View logs
kamal lock release        # Release stuck lock
kamal secrets print       # Print evaluated secrets
```

package collector

import (
	"context"
	"encoding/json"
	"io"

	"github.com/docker/docker/api/types"
	"github.com/docker/docker/api/types/container"
	"github.com/docker/docker/client"
)

func CollectContainers() []ContainerMetrics {
	cli, err := client.NewClientWithOpts(client.FromEnv, client.WithAPIVersionNegotiation())
	if err != nil {
		return nil
	}
	defer cli.Close()

	containers, err := cli.ContainerList(context.Background(), container.ListOptions{})
	if err != nil {
		return nil
	}

	var metrics []ContainerMetrics
	for _, c := range containers {
		name := ""
		if len(c.Names) > 0 {
			name = c.Names[0]
			if len(name) > 0 && name[0] == '/' {
				name = name[1:]
			}
		}

		cm := ContainerMetrics{
			ID:        c.ID[:12],
			Name:      name,
			Image:     c.Image,
			Status:    c.State,
			StartedAt: c.Created,
			Labels:    c.Labels,
		}

		// Get stats
		stats, err := cli.ContainerStats(context.Background(), c.ID, false)
		if err == nil {
			cm.Stats = parseContainerStats(stats)
			stats.Body.Close()
		}

		metrics = append(metrics, cm)
	}

	return metrics
}

func parseContainerStats(stats types.ContainerStats) *ContainerStats {
	var v types.StatsJSON
	decoder := json.NewDecoder(stats.Body)
	if err := decoder.Decode(&v); err != nil {
		if err != io.EOF {
			return nil
		}
	}

	cs := &ContainerStats{}

	// CPU
	cpuDelta := float64(v.CPUStats.CPUUsage.TotalUsage - v.PreCPUStats.CPUUsage.TotalUsage)
	systemDelta := float64(v.CPUStats.SystemUsage - v.PreCPUStats.SystemUsage)
	if systemDelta > 0 && cpuDelta > 0 {
		cs.CPUPercent = (cpuDelta / systemDelta) * float64(len(v.CPUStats.CPUUsage.PercpuUsage)) * 100.0
	}

	// Memory
	cs.MemoryUsed = v.MemoryStats.Usage
	cs.MemoryLimit = v.MemoryStats.Limit
	if cs.MemoryLimit > 0 {
		cs.MemoryPercent = float64(cs.MemoryUsed) / float64(cs.MemoryLimit) * 100.0
	}

	// Network
	for _, net := range v.Networks {
		cs.NetworkRx += net.RxBytes
		cs.NetworkTx += net.TxBytes
	}

	// Block I/O
	for _, bio := range v.BlkioStats.IoServiceBytesRecursive {
		if bio.Op == "Read" {
			cs.BlockRead += bio.Value
		}
		if bio.Op == "Write" {
			cs.BlockWrite += bio.Value
		}
	}

	// PIDs
	cs.PIDs = v.PidsStats.Current

	return cs
}

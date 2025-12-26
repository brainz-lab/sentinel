package collector

import (
	"github.com/shirou/gopsutil/v3/net"
)

func CollectNetwork(excludedInterfaces []string) []NetworkMetrics {
	var metrics []NetworkMetrics

	counters, _ := net.IOCounters(true)
	for _, c := range counters {
		// Skip excluded interfaces
		if isExcludedInterface(c.Name, excludedInterfaces) {
			continue
		}

		nm := NetworkMetrics{
			Interface:   c.Name,
			BytesSent:   c.BytesSent,
			BytesRecv:   c.BytesRecv,
			PacketsSent: c.PacketsSent,
			PacketsRecv: c.PacketsRecv,
			ErrorsIn:    c.Errin,
			ErrorsOut:   c.Errout,
			DropsIn:     c.Dropin,
			DropsOut:    c.Dropout,
		}

		metrics = append(metrics, nm)
	}

	// TCP connection stats (add to first interface)
	if len(metrics) > 0 {
		conns, _ := net.Connections("tcp")
		metrics[0].TCPConns = len(conns)

		established := 0
		for _, c := range conns {
			if c.Status == "ESTABLISHED" {
				established++
			}
		}
		metrics[0].TCPEstablished = established
	}

	return metrics
}

func isExcludedInterface(name string, excludedInterfaces []string) bool {
	for _, excluded := range excludedInterfaces {
		if name == excluded {
			return true
		}
	}
	return false
}

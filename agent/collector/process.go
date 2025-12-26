package collector

import (
	"sort"

	"github.com/shirou/gopsutil/v3/process"
)

func CollectProcesses(limit int) []ProcessMetrics {
	procs, _ := process.Processes()

	var metrics []ProcessMetrics
	for _, p := range procs {
		cpu, _ := p.CPUPercent()
		mem, _ := p.MemoryPercent()

		pm := ProcessMetrics{
			PID:           p.Pid,
			CPUPercent:    cpu,
			MemoryPercent: mem,
		}

		if name, err := p.Name(); err == nil {
			pm.Name = name
		}
		if ppid, err := p.Ppid(); err == nil {
			pm.PPID = ppid
		}
		if cmdline, err := p.Cmdline(); err == nil {
			// Truncate long commands
			if len(cmdline) > 500 {
				cmdline = cmdline[:500]
			}
			pm.Command = cmdline
		}
		if user, err := p.Username(); err == nil {
			pm.User = user
		}
		if memInfo, err := p.MemoryInfo(); err == nil {
			pm.MemoryRSS = memInfo.RSS
			pm.MemoryVMS = memInfo.VMS
		}
		if threads, err := p.NumThreads(); err == nil {
			pm.Threads = threads
		}
		if fds, err := p.NumFDs(); err == nil {
			pm.FDs = fds
		}

		metrics = append(metrics, pm)
	}

	// Sort by CPU and return top N
	sort.Slice(metrics, func(i, j int) bool {
		return metrics[i].CPUPercent > metrics[j].CPUPercent
	})

	if len(metrics) > limit {
		metrics = metrics[:limit]
	}

	return metrics
}

package collector

import (
	"runtime"

	"github.com/shirou/gopsutil/v3/cpu"
	"github.com/shirou/gopsutil/v3/host"
	"github.com/shirou/gopsutil/v3/load"
	"github.com/shirou/gopsutil/v3/mem"
	"github.com/shirou/gopsutil/v3/net"
	"github.com/shirou/gopsutil/v3/process"
)

func CollectSystem() *SystemMetrics {
	metrics := &SystemMetrics{}

	// CPU times
	times, _ := cpu.Times(false)
	if len(times) > 0 {
		total := times[0].User + times[0].System + times[0].Idle + times[0].Iowait + times[0].Steal
		if total > 0 {
			metrics.CPUUser = times[0].User / total * 100
			metrics.CPUSystem = times[0].System / total * 100
			metrics.CPUIowait = times[0].Iowait / total * 100
			metrics.CPUSteal = times[0].Steal / total * 100
		}
	}

	// CPU percent
	percent, _ := cpu.Percent(0, false)
	if len(percent) > 0 {
		metrics.CPUUsage = percent[0]
	}

	// Load averages
	loadAvg, _ := load.Avg()
	if loadAvg != nil {
		metrics.Load1m = loadAvg.Load1
		metrics.Load5m = loadAvg.Load5
		metrics.Load15m = loadAvg.Load15
	}

	// Memory
	vmem, _ := mem.VirtualMemory()
	if vmem != nil {
		metrics.MemoryUsed = vmem.Used
		metrics.MemoryFree = vmem.Free
		metrics.MemoryAvail = vmem.Available
		metrics.MemoryCached = vmem.Cached
		metrics.MemoryUsage = vmem.UsedPercent
	}

	// Swap
	swap, _ := mem.SwapMemory()
	if swap != nil {
		metrics.SwapUsed = swap.Used
		metrics.SwapFree = swap.Free
		metrics.SwapUsage = swap.UsedPercent
	}

	// Process counts
	procs, _ := process.Processes()
	metrics.ProcsTotal = len(procs)
	for _, p := range procs {
		status, _ := p.Status()
		if len(status) > 0 && status[0] == "R" {
			metrics.ProcsRunning++
		}
	}

	// Uptime
	uptime, _ := host.Uptime()
	metrics.Uptime = uptime

	return metrics
}

func CollectSystemInfo() *SystemInfo {
	info := &SystemInfo{}

	// Host info
	hostInfo, _ := host.Info()
	if hostInfo != nil {
		info.OS = hostInfo.OS
		info.OSVersion = hostInfo.PlatformVersion
		info.KernelVer = hostInfo.KernelVersion
		info.Arch = hostInfo.KernelArch
	}

	// CPU info
	cpuInfo, _ := cpu.Info()
	if len(cpuInfo) > 0 {
		info.CPUModel = cpuInfo[0].ModelName
	}

	// CPU counts
	cores, _ := cpu.Counts(false)
	threads, _ := cpu.Counts(true)
	info.CPUCores = cores
	info.CPUThreads = threads

	// Memory
	vmem, _ := mem.VirtualMemory()
	if vmem != nil {
		info.MemoryTotal = vmem.Total
	}

	// Swap
	swap, _ := mem.SwapMemory()
	if swap != nil {
		info.SwapTotal = swap.Total
	}

	// Network interfaces
	interfaces, _ := net.Interfaces()
	for _, iface := range interfaces {
		if iface.Name == "lo" {
			continue
		}
		for _, addr := range iface.Addrs {
			info.IPAddresses = append(info.IPAddresses, addr.Addr)
		}
		if iface.HardwareAddr != "" {
			info.MACAddresses = append(info.MACAddresses, iface.HardwareAddr)
		}
	}

	// Detect private IP
	for _, ip := range info.IPAddresses {
		if isPrivateIP(ip) {
			info.PrivateIP = ip
			break
		}
	}

	// Set architecture
	info.Arch = runtime.GOARCH

	return info
}

func isPrivateIP(ip string) bool {
	// Simple check for private IP ranges
	if len(ip) > 3 {
		prefix := ip[:3]
		return prefix == "10." || prefix == "172" || prefix == "192"
	}
	return false
}

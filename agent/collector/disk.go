package collector

import (
	"strings"

	"github.com/shirou/gopsutil/v3/disk"
)

func CollectDisks(excludedMounts []string) []DiskMetrics {
	var metrics []DiskMetrics

	partitions, _ := disk.Partitions(false)
	for _, p := range partitions {
		// Skip excluded mounts
		if isExcluded(p.Mountpoint, excludedMounts) {
			continue
		}

		usage, err := disk.Usage(p.Mountpoint)
		if err != nil {
			continue
		}

		dm := DiskMetrics{
			Device:       p.Device,
			MountPoint:   p.Mountpoint,
			Filesystem:   p.Fstype,
			Total:        usage.Total,
			Used:         usage.Used,
			Free:         usage.Free,
			UsagePercent: usage.UsedPercent,
			InodesTotal:  usage.InodesTotal,
			InodesUsed:   usage.InodesUsed,
			InodesFree:   usage.InodesFree,
		}

		// I/O stats (extract device name for IO counters)
		deviceName := extractDeviceName(p.Device)
		ioCounters, _ := disk.IOCounters(deviceName)
		if counter, ok := ioCounters[deviceName]; ok {
			dm.ReadBytes = counter.ReadBytes
			dm.WriteBytes = counter.WriteBytes
		}

		metrics = append(metrics, dm)
	}

	return metrics
}

func isExcluded(mount string, excludedMounts []string) bool {
	for _, excluded := range excludedMounts {
		if strings.HasPrefix(mount, excluded) {
			return true
		}
	}
	return false
}

func extractDeviceName(device string) string {
	// Extract device name from path like /dev/sda1 -> sda1
	parts := strings.Split(device, "/")
	if len(parts) > 0 {
		return parts[len(parts)-1]
	}
	return device
}

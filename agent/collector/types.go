package collector

import "time"

type Payload struct {
	AgentID    string              `json:"agent_id"`
	Hostname   string              `json:"hostname"`
	Timestamp  time.Time           `json:"timestamp"`
	System     *SystemMetrics      `json:"system,omitempty"`
	Disks      []DiskMetrics       `json:"disks,omitempty"`
	Network    []NetworkMetrics    `json:"network,omitempty"`
	Processes  []ProcessMetrics    `json:"processes,omitempty"`
	Containers []ContainerMetrics  `json:"containers,omitempty"`
}

type SystemMetrics struct {
	CPUUsage     float64 `json:"cpu_usage"`
	CPUUser      float64 `json:"cpu_user"`
	CPUSystem    float64 `json:"cpu_system"`
	CPUIowait    float64 `json:"cpu_iowait"`
	CPUSteal     float64 `json:"cpu_steal"`
	Load1m       float64 `json:"load_1m"`
	Load5m       float64 `json:"load_5m"`
	Load15m      float64 `json:"load_15m"`
	MemoryUsed   uint64  `json:"memory_used"`
	MemoryFree   uint64  `json:"memory_free"`
	MemoryAvail  uint64  `json:"memory_available"`
	MemoryCached uint64  `json:"memory_cached"`
	MemoryUsage  float64 `json:"memory_usage"`
	SwapUsed     uint64  `json:"swap_used"`
	SwapFree     uint64  `json:"swap_free"`
	SwapUsage    float64 `json:"swap_usage"`
	ProcsTotal   int     `json:"processes_total"`
	ProcsRunning int     `json:"processes_running"`
	Uptime       uint64  `json:"uptime"`
}

type SystemInfo struct {
	OS           string   `json:"os"`
	OSVersion    string   `json:"os_version"`
	KernelVer    string   `json:"kernel_version"`
	Arch         string   `json:"architecture"`
	CPUModel     string   `json:"cpu_model"`
	CPUCores     int      `json:"cpu_cores"`
	CPUThreads   int      `json:"cpu_threads"`
	MemoryTotal  uint64   `json:"memory_total"`
	SwapTotal    uint64   `json:"swap_total"`
	IPAddresses  []string `json:"ip_addresses"`
	PublicIP     string   `json:"public_ip,omitempty"`
	PrivateIP    string   `json:"private_ip,omitempty"`
	MACAddresses []string `json:"mac_addresses"`
}

type DiskMetrics struct {
	Device       string  `json:"device"`
	MountPoint   string  `json:"mount_point"`
	Filesystem   string  `json:"filesystem"`
	Total        uint64  `json:"total"`
	Used         uint64  `json:"used"`
	Free         uint64  `json:"free"`
	UsagePercent float64 `json:"usage_percent"`
	InodesTotal  uint64  `json:"inodes_total"`
	InodesUsed   uint64  `json:"inodes_used"`
	InodesFree   uint64  `json:"inodes_free"`
	ReadBytes    uint64  `json:"read_bytes"`
	WriteBytes   uint64  `json:"write_bytes"`
}

type NetworkMetrics struct {
	Interface      string `json:"name"`
	BytesSent      uint64 `json:"bytes_sent"`
	BytesRecv      uint64 `json:"bytes_received"`
	PacketsSent    uint64 `json:"packets_sent"`
	PacketsRecv    uint64 `json:"packets_received"`
	ErrorsIn       uint64 `json:"errors_in"`
	ErrorsOut      uint64 `json:"errors_out"`
	DropsIn        uint64 `json:"drops_in"`
	DropsOut       uint64 `json:"drops_out"`
	TCPConns       int    `json:"tcp_connections"`
	TCPEstablished int    `json:"tcp_established"`
}

type ProcessMetrics struct {
	PID           int32   `json:"pid"`
	PPID          int32   `json:"ppid"`
	Name          string  `json:"name"`
	Command       string  `json:"command"`
	User          string  `json:"user"`
	State         string  `json:"state"`
	CPUPercent    float64 `json:"cpu_percent"`
	MemoryPercent float32 `json:"memory_percent"`
	MemoryRSS     uint64  `json:"memory_rss"`
	MemoryVMS     uint64  `json:"memory_vms"`
	Threads       int32   `json:"threads"`
	FDs           int32   `json:"fds"`
}

type ContainerMetrics struct {
	ID        string            `json:"id"`
	Name      string            `json:"name"`
	Image     string            `json:"image"`
	Status    string            `json:"status"`
	StartedAt int64             `json:"started_at"`
	Labels    map[string]string `json:"labels"`
	Stats     *ContainerStats   `json:"stats,omitempty"`
}

type ContainerStats struct {
	CPUPercent    float64 `json:"cpu_percent"`
	MemoryUsed    uint64  `json:"memory_used"`
	MemoryLimit   uint64  `json:"memory_limit"`
	MemoryPercent float64 `json:"memory_percent"`
	NetworkRx     uint64  `json:"network_rx"`
	NetworkTx     uint64  `json:"network_tx"`
	BlockRead     uint64  `json:"block_read"`
	BlockWrite    uint64  `json:"block_write"`
	PIDs          uint64  `json:"pids"`
}

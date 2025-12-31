class ProcessSnapshot < ApplicationRecord
  belongs_to :host

  scope :recent, -> { where("recorded_at > ?", 5.minutes.ago) }
  scope :by_cpu, -> { order(cpu_percent: :desc) }
  scope :by_memory, -> { order(memory_percent: :desc) }

  def memory_rss_mb
    (memory_rss_bytes.to_f / 1.megabyte).round(1)
  end

  def memory_vms_mb
    (memory_vms_bytes.to_f / 1.megabyte).round(1)
  end
end

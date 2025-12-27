module Dashboard
  class HostsController < BaseController
    before_action :set_host, only: [:show, :edit, :update, :destroy, :metrics, :processes, :containers]

    def index
      @hosts = Host.includes(:host_group).order(created_at: :desc)
    end

    def show
    end

    def new
      @host = Host.new
    end

    def create
      @host = Host.new(host_params)
      if @host.save
        redirect_to dashboard_host_path(@host), notice: "Host created successfully"
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      if @host.update(host_params)
        redirect_to dashboard_host_path(@host), notice: "Host updated successfully"
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @host.destroy
      redirect_to dashboard_hosts_path, notice: "Host deleted successfully"
    end

    def metrics
      @metrics = @host.host_metrics.order(recorded_at: :desc).limit(100)
    end

    def processes
      @processes = @host.process_snapshots.order(recorded_at: :desc).first&.processes || []
    end

    def containers
      @containers = @host.containers.includes(:container_metrics)
    end

    private

    def set_host
      @host = Host.find(params[:id])
    end

    def host_params
      params.require(:host).permit(:hostname, :display_name, :host_group_id, :tags)
    end
  end
end

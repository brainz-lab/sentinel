module Dashboard
  class HostsController < BaseController
    before_action :require_project!
    before_action :set_host, only: [:show, :edit, :update, :destroy, :metrics, :processes, :containers]

    def index
      @hosts = current_project.hosts.includes(:host_group).order(created_at: :desc)
      @host_groups = current_project.host_groups
    end

    def show
      @metrics = @host.host_metrics.order(recorded_at: :desc).limit(60)
      @disk_usage = @host.disk_usage
      @containers = @host.containers.limit(10)
    end

    def new
      @host = current_project.hosts.build
      @host_groups = current_project.host_groups
    end

    def create
      @host = current_project.hosts.build(host_params)
      if @host.save
        redirect_to dashboard_project_host_path(current_project, @host), notice: "Host created successfully"
      else
        @host_groups = current_project.host_groups
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      @host_groups = current_project.host_groups
    end

    def update
      if @host.update(host_params)
        redirect_to dashboard_project_host_path(current_project, @host), notice: "Host updated successfully"
      else
        @host_groups = current_project.host_groups
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @host.destroy
      redirect_to dashboard_project_hosts_path(current_project), notice: "Host deleted successfully"
    end

    def metrics
      @metrics = @host.host_metrics.order(recorded_at: :desc).limit(100)
    end

    def processes
      @processes = @host.top_processes(limit: 20)
    end

    def containers
      @containers = @host.containers.includes(:container_metrics)
    end

    private

    def set_host
      @host = current_project.hosts.find(params[:id])
    end

    def host_params
      params.require(:host).permit(:name, :hostname, :host_group_id, :environment, :role, tags: {})
    end
  end
end

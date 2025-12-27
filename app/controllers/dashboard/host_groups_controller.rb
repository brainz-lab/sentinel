module Dashboard
  class HostGroupsController < BaseController
    before_action :require_project!
    before_action :set_host_group, only: [:show, :edit, :update, :destroy]

    def index
      @host_groups = current_project.host_groups.includes(:hosts).order(:name)
    end

    def show
      @hosts = @host_group.hosts.includes(:host_metrics).order(:hostname)
    end

    def new
      @host_group = current_project.host_groups.build
    end

    def create
      @host_group = current_project.host_groups.build(host_group_params)
      if @host_group.save
        redirect_to dashboard_project_host_group_path(current_project, @host_group), notice: "Host group created successfully"
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      if @host_group.update(host_group_params)
        redirect_to dashboard_project_host_group_path(current_project, @host_group), notice: "Host group updated successfully"
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @host_group.destroy
      redirect_to dashboard_project_host_groups_path(current_project), notice: "Host group deleted successfully"
    end

    private

    def set_host_group
      @host_group = current_project.host_groups.find(params[:id])
    end

    def host_group_params
      params.require(:host_group).permit(:name, :description, auto_assign_rules: [:field, :operator, :value])
    end
  end
end

module Dashboard
  class HostGroupsController < BaseController
    before_action :set_host_group, only: [:show, :edit, :update, :destroy]

    def index
      @host_groups = HostGroup.includes(:hosts).order(:name)
    end

    def show
      @hosts = @host_group.hosts.order(:hostname)
    end

    def new
      @host_group = HostGroup.new
    end

    def create
      @host_group = HostGroup.new(host_group_params)
      if @host_group.save
        redirect_to dashboard_host_group_path(@host_group), notice: "Host group created successfully"
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      if @host_group.update(host_group_params)
        redirect_to dashboard_host_group_path(@host_group), notice: "Host group updated successfully"
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @host_group.destroy
      redirect_to dashboard_host_groups_path, notice: "Host group deleted successfully"
    end

    private

    def set_host_group
      @host_group = HostGroup.find(params[:id])
    end

    def host_group_params
      params.require(:host_group).permit(:name, :description, :auto_assign_rules)
    end
  end
end

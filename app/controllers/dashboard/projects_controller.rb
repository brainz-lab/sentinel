module Dashboard
  class ProjectsController < BaseController
    skip_before_action :set_current_project, only: [ :index, :new, :create ]

    def index
      @projects = Project.order(:name)
    end

    def show
      redirect_to dashboard_project_overview_path(@current_project)
    end

    def new
      @project = Project.new
    end

    def create
      @project = Project.new(project_params)
      if @project.save
        redirect_to dashboard_project_overview_path(@project), notice: "Project created successfully"
      else
        render :new, status: :unprocessable_entity
      end
    end

    private

    def project_params
      params.require(:project).permit(:name, :platform_project_id, :environment)
    end
  end
end

module Api
  module V1
    class HostGroupsController < BaseController
      before_action :set_host_group, only: [ :show, :update, :destroy ]

      # GET /api/v1/host_groups
      def index
        groups = HostGroup.for_project(@project_id)

        render json: {
          host_groups: groups.map { |g| group_summary(g) }
        }
      end

      # GET /api/v1/host_groups/:id
      def show
        render json: {
          host_group: group_details(@host_group)
        }
      end

      # POST /api/v1/host_groups
      def create
        group = HostGroup.new(host_group_params)
        group.platform_project_id = @project_id

        if group.save
          render json: { host_group: group_details(group) }, status: :created
        else
          render json: { errors: group.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # PATCH /api/v1/host_groups/:id
      def update
        if @host_group.update(host_group_params)
          render json: { host_group: group_details(@host_group) }
        else
          render json: { errors: @host_group.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # DELETE /api/v1/host_groups/:id
      def destroy
        @host_group.destroy!
        head :no_content
      end

      private

      def set_host_group
        @host_group = HostGroup.for_project(@project_id).find(params[:id])
      end

      def host_group_params
        params.require(:host_group).permit(:name, :description, :color, auto_assign_rules: [ :field, :operator, :value ])
      end

      def group_summary(group)
        {
          id: group.id,
          name: group.name,
          description: group.description,
          color: group.color,
          host_count: group.host_count,
          avg_cpu: group.average_cpu,
          avg_memory: group.average_memory
        }
      end

      def group_details(group)
        group_summary(group).merge(
          auto_assign_rules: group.auto_assign_rules,
          hosts: group.hosts.map { |h| { id: h.id, name: h.name, status: h.status } },
          created_at: group.created_at.iso8601,
          updated_at: group.updated_at.iso8601
        )
      end
    end
  end
end

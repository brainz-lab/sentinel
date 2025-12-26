module Mcp
  class ToolsController < ApplicationController
    TOOLS = {
      'sentinel_list_hosts' => Mcp::Tools::ListHosts,
      'sentinel_host_status' => Mcp::Tools::HostStatus,
      'sentinel_host_metrics' => Mcp::Tools::HostMetrics,
      'sentinel_top_processes' => Mcp::Tools::TopProcesses,
      'sentinel_fleet_overview' => Mcp::Tools::FleetOverview
    }.freeze

    # GET /mcp/tools
    def list
      render json: {
        tools: TOOLS.map do |name, klass|
          {
            name: name,
            description: klass::DESCRIPTION,
            schema: klass::SCHEMA
          }
        end
      }
    end

    # POST /mcp/tools/:tool
    def execute
      tool_class = TOOLS[params[:tool]]

      unless tool_class
        render json: { error: "Unknown tool: #{params[:tool]}" }, status: :not_found
        return
      end

      tool = tool_class.new(@project_id)
      result = tool.call(tool_params)

      render json: result
    rescue StandardError => e
      render json: { error: e.message }, status: :unprocessable_entity
    end

    private

    def tool_params
      params.permit!.to_h.deep_symbolize_keys.except(:tool, :controller, :action)
    end

    def set_project_context
      @project_id = current_project&.id || 'development'
    end
  end
end

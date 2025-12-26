module Mcp
  module Tools
    class Base
      TOOL_NAME = 'base'
      DESCRIPTION = 'Base tool'
      SCHEMA = {}.freeze

      def initialize(project_id)
        @project_id = project_id
      end

      def call(args)
        raise NotImplementedError
      end

      protected

      def hosts
        Host.for_project(@project_id)
      end

      def host_groups
        HostGroup.for_project(@project_id)
      end
    end
  end
end

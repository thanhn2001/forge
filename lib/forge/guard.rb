require 'listen'

module Forge
  class Guard

    def initialize(project, task, options = {})
      @project = project
      @task    = task
      @builder = Builder.new(project)
    end

    def start!
      @builder.clean_all

      options = {
        ignore: /\/\.[^\/]$/ # Hidden files
      }
      Listen.to(@project.source_path, options) do |modified, added, removed|

        # This is all just proof of concept and will be promptly refined

        modified.each do |path|
          type = identify_file path
          case type
          when :asset
            @task.say 'Recompiling assets'
            @builder.compile_assets
          when :template
            @builder.copy_templates
          when :function
            @builder.copy_functions
          when :include
            @builder.copy_includes
          end
        end

        added.each do |path|
          type = identify_file path
          case type
          when :asset
            @task.say 'Recompiling assets'
            @builder.compile_assets
          when :template
            @builder.copy_templates
          when :function
            @builder.copy_functions
          when :include
            @builder.copy_includes
          end
        end

        removed.each do |path|
          type = identify_file path
          case type
          when :asset
            @task.say 'Recompiling assets'
            @builder.compile_assets
          when :template
            @builder.copy_templates
          when :function
            @builder.copy_functions
          when :include
            @builder.copy_includes
          end
        end
      end

      sleep
    end

    def identify_file(path)
      type = path.match(/source\/([a-z]+)\//)[1]
      type[0..-2].to_sym
    end

  end
end

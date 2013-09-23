require 'listen'

module Forge
  class Guard

    LISTEN_ACTIONS = [:modified, :added, :removed]

    def initialize(project, task, options = {})
      @project = project
      @task    = task
      @builder = Builder.new(project)
    end

    # Tells the builder to recompile assets when an asset is changed
    #
    # I can't see a way & reason to not always rebuild assets. Sprockets
    # is smart enough not to recompile files when it doesn't need to.
    #
    # @return [void]
    def asset_modified(path)
      @task.say 'Recompiling assets'
      @builder.compile_assets
    end
    alias_method :asset_added, :asset_modified
    alias_method :asset_removed, :asset_modified

    def template_modified(path)
      @task.say "Modified template: #{ path }"
      @builder.copy_template(path)
    end
    alias_method :template_added, :template_modified

    def template_removed(path)
      @task.say "Removed template: #{ path }"
      @builder.clean_template(path)
    end

    def function_modified(path)
      @builder.copy_functions
    end
    alias_method :function_added, :function_modified

    def function_removed(path)
      @builder.clean_functions
      @builder.copy_functions
    end

    def include_modified(path)
      @builder.copy_includes
    end
    alias_method :include_added, :include_modified

    def include_removed(path)
      @builder.clean_includes
      @builder.copy_includes
    end

    def start!
      @builder.clean_all

      options = {
        ignore: /\/\.[^\/]$/ # Hidden files
      }
      # |modified, added, removed|
      Listen.to(@project.source_path, options) do |*args|
        # All paths here are absolute
        LISTEN_ACTIONS.each_with_index do |action, index|
          paths = args[index]
          paths.each do |path|
            type = identify_file path
            method = "#{ type }_#{ action }"
            send(method, path)
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

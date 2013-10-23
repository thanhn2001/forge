module Forge
  class Builder

    def initialize(project)
      @project = project
      @config  = project.config
      @assets  = project.assets
      @task    = project.task
    end

    # Runs all the methods necessary to build a completed project
    #
    # @return [void]
    def build
      clean_all

      FileUtils.mkdir_p(@project.build_path) unless @project.build_path.exist?

      copy_templates
      copy_functions
      copy_includes
      compile_assets
    end

    # Completely empties out the build directory
    #
    # @return [void]
    def clean_all
      FileUtils.rm_r Dir.glob @project.build_path.join('*')
    end

    # Removes a single file from the build directory.
    #
    # @param [String|Pathname] path Relative from build_path
    #
    # @return [void]
    def clean_file(filename)
      @project.build_path.join(filename).unlink
    end

    # Removes all templates from the build directory
    #
    # @return [void]
    def clean_templates
      Dir.glob(@project.build_path.join('**/*.php')).each do |path|
        clean_template(path)
      end
    end

    # Removes a single template from the build directory
    #
    # @param [String|Pathname] path Absolute path to source template
    #
    # @return [void]
    def clean_template(path)
      dest = template_destination(path)
      dest.unlink if dest.exist? && path.to_s !~ /functions\.php|includes\//
    end

    # Copies all templates to the build directory
    #
    # @return [void]
    def copy_templates
      Dir.glob(@project.templates_path.join('**', '*')).each do |path|
        copy_template(path)
      end
    end

    # Copies a single template to the build directory
    #
    # @param [String|Pathname] path Absolute path to source template
    #
    # @return [void]
    def copy_template(path)
      dest = template_destination(path)

      if File.directory?(path) && !dest.exist?
        FileUtils.mkdir_p dest
      else
        # TODO restore ERB functionality
        FileUtils.cp path, dest
      end
    end

    # Removes all functions from the build directory
    #
    # Deletes `functions.php` and `functions/`
    #
    # @return [void]
    def clean_functions
      FileUtils.rm @project.build_path.join('functions.php')
      FileUtils.rm_rf @project.build_path.join('functions')
    end

    # Copies all functions to the build directory
    #
    # @return [void]
    def copy_functions
      return unless @project.functions_path.exist?

      functions_file_path = @project.functions_path.join('functions.php')
      FileUtils.cp functions_file_path, @project.build_path if functions_file_path.exist?

      functions_paths = Dir.glob(File.join(@project.functions_path, '**', '*'))
      functions_paths.delete(functions_file_path.to_s)

      unless functions_paths.empty?
        functions_dir = @project.build_path.join('functions')
        FileUtils.mkdir_p(functions_dir)
        FileUtils.cp(functions_paths, functions_dir)
      end
    end

    # Removes all includes from the build directory
    #
    # @return [void]
    def clean_includes
      FileUtils.rm_r @project.build_path.join('includes')
    end

    # Copies all includes to the build directory
    #
    # @return [void]
    def copy_includes
      return unless @project.includes_path.exist?

      paths = Dir.glob(@project.includes_path.join('**', '*'))
      if !paths.empty?
        dest = @project.build_path.join('includes')
        FileUtils.mkdir(dest) unless dest.directory?
        FileUtils.cp(paths, dest)
      end
    end

    def clean_asset(filename)
      @project.build_path.join(filename).unlink
    end

    def compile_asset(filename)
      begin
        @assets[filename].write_to @project.build_path.join(filename)
      rescue Exception => e
        @task.say "Error while building #{ filename }:"
        @task.say e.message, Thor::Shell::Color::RED
        File.open(destination, 'w') { |f| file.puts(e.message) }
      end
    end

    def compile_assets
      @assets.each_logical_path(*@config.assets.precompile).each do |filename|
        compile_asset(filename)
      end
    end

    protected

    # @return Pathname
    def template_destination(path)
      path = Pathname.new(path)
      filename = path.relative_path_from(@project.templates_path)
      @project.build_path.join(filename)
    end

  end
end

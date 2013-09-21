require 'sprockets'
require 'sprockets-sass'
require 'sass'

module Forge
  class Builder

    LOOSE_ASSETS = lambda do |filename, path|
      path =~ /source\/assets/ && filename !~ /^_|\/_/ #&& %w[.js .css].include?(File.extname(filename))
    end

    def initialize(project)
      @project = project
      @task    = project.task

      init_sprockets
    end

    # Runs all the methods necessary to build a completed project
    #
    # @return [void]
    def build
      clean_all
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

    # Removes all templates from the build directory
    #
    # @return [void]
    def clean_templates
      Dir.glob(@project.build_path.join('**/*.php')).each do |path|
        # `path` is a absolute
        FileUtils.rm(path) unless path =~ /functions\.php|includes\//
      end
    end

    # Copies all templates to the build directory
    #
    # @return [void]
    def copy_templates
      # TODO restore ERB functionality
      FileUtils.cp_r "#{ @project.templates_path.to_s }/.", @project.build_path
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
      FileUtils.rm_rf @project.build_path.join('includes')
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

        # TODO JASON LOLO WAT?
        # Re-initializing sprockets to prevent further errors
        # TODO: This is done for lack of a better solution
        init_sprockets
      end
    end

    def compile_assets
      precompile = [LOOSE_ASSETS, 'style.css', 'theme.js']
      @assets.each_logical_path(*precompile).each do |filename|
        p filename
        compile_asset(filename)
      end
    end

    private

    def init_sprockets
      @assets = Sprockets::Environment.new

      @assets.append_path @project.javascripts_path
      @assets.append_path @project.stylesheets_path
      @assets.append_path @project.images_path
      @assets.append_path @project.fonts_path

      # Passing the @project instance variable to the Sprockets::Context instance
      # used for processing the asset ERB files. Ruby meta-programming, FTW.
      @assets.context_class.instance_exec(@project) do |project|
        define_method :config do
          project.config
        end
      end
    end

  end
end

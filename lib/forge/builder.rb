require 'sprockets'
require 'sprockets-sass'
require 'sass'

module Forge
  class Builder
    def initialize(project)
      @project = project
      @task    = project.task

      init_sprockets
    end

    # Runs all the methods necessary to build a completed project
    #
    # @return [void]
    def build
      clean_build_directory
      copy_templates
      copy_functions
      copy_includes
      build_assets
    end

    # Completely empties out the build directory
    #
    # @return [void]
    def clean_build_directory
      FileUtils.rm_rf @project.build_path.join('*')
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

    # Removes all images from the build directory
    #
    # @return [void]
    def clean_images
      FileUtils.rm_rf @project.build_path.join('images')
    end

    def build_assets
      @project.compiled_assets.each do |asset_file|
        destination = @project.build_path.join(asset_file)
        asset = @sprockets.find_asset(asset_file)

        begin
          if !asset.nil?
            puts "Compiling #{ asset.logical_path } ..."
            asset.write_to(destination)
          end
        rescue Exception => e
          @task.say "Error while building #{ asset.logical_path }:"
          @task.say e.message, Thor::Shell::Color::RED
          File.open(destination, 'w') do |file|
            file.puts(e.message)
          end

          # TODO JASON LOLO WAT?
          # Re-initializing sprockets to prevent further errors
          # TODO: This is done for lack of a better solution
          init_sprockets
        end
      end

      # Copy the images & fonts directly directory over
      FileUtils.cp_r(@project.images_path, @project.build_path)
      FileUtils.cp_r(@project.fonts_path, @project.build_path) if @project.fonts_path.exist?

      # Check for screenshot and move it into main build directory
      Dir.glob(File.join(@project.build_path, 'images', '*')).each do |filename|
        if filename.index(/screenshot\.(png|jpg|jpeg|gif)/)
          FileUtils.mv(filename, @project.build_path + File::SEPARATOR )
        end
      end
    end

    private

    def init_sprockets
      @sprockets = Sprockets::Environment.new

      @sprockets.append_path @project.javascripts_path
      @sprockets.append_path @project.stylesheets_path
      @sprockets.append_path @project.fonts_path

      # Passing the @project instance variable to the Sprockets::Context instance
      # used for processing the asset ERB files. Ruby meta-programming, FTW.
      @sprockets.context_class.instance_exec(@project) do |project|
        define_method :config do
          project.config
        end
      end
    end

  end
end

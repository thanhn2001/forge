require 'sprockets'
require 'sprockets-sass'
require 'sass'

module Forge
  class Builder
    def initialize(project)
      @project = project
      @task    = project.task
      @templates_path = @project.templates_path
      @assets_path = @project.assets_path
      @functions_path = @project.functions_path
      @includes_path = @project.includes_path
      @package_path = @project.package_path

      init_sprockets
    end

    # Runs all the methods necessary to build a completed project
    def build
      clean_build_directory
      copy_templates
      copy_functions
      copy_includes
      build_assets
    end

    # Empty out the build directory
    def clean_build_directory
      FileUtils.rm_rf @project.build_path.join('*')
    end

    def clean_templates
      Dir.glob(@project.build_path.join('**/*.php')).each do |path|
        # `path` is a absolute
        FileUtils.rm(path) unless path =~ /functions\.php|includes\//
      end
    end

    def copy_templates
      # TODO restore ERB functionality
      FileUtils.cp_r "#{ @templates_path.to_s }/.", @project.build_path
    end

    def clean_functions
      FileUtils.rm @project.build_path.join('functions.php')
      FileUtils.rm_rf @project.build_path.join('functions')
    end

    def copy_functions
      functions_erb_path = File.join(@functions_path, 'functions.php.erb')
      functions_php_path = File.join(@functions_path, 'functions.php')

      if File.exists?(functions_erb_path)
        destination = File.join(@project.build_path, 'functions.php')
        write_erb(functions_erb_path, destination)
      elsif File.exists?(functions_php_path)
        FileUtils.cp functions_php_path, @project.build_path
      end

      functions_paths = Dir.glob(@functions_path.join('*')).reject do |filename|
        [functions_erb_path, functions_php_path].include?(filename)
      end

      unless functions_paths.empty?
        # Create the includes folder in the build directory
        FileUtils.mkdir_p(File.join(@project.build_path, 'functions'))

        # Iterate over all files in source/functions, skipping the actual functions.php file
        paths = Dir.glob(File.join(@functions_path, '**', '*')).reject {|filename| [functions_erb_path, functions_php_path].include?(filename) }

        copy_paths_with_erb(paths, @functions_path, @project.build_path.join('functions'))
      end
    end

    def clean_includes
      FileUtils.rm_rf @project.build_path.join('includes')
    end

    def copy_includes
      unless Dir.glob(File.join(@includes_path, '*')).empty?
        # Create the includes folder in the build directory
        FileUtils.mkdir(@project.build_path.join('includes'))

        # Iterate over all files in source/includes, so we can exclude if necessary
        paths = Dir.glob(@includes_path.join('**', '*'))
        copy_paths_with_erb(paths, @includes_path, @project.build_path.join('includes'))
      end
    end

    def clean_images
      FileUtils.rm_rf @project.build_path.join('images')
    end

    def build_assets
      @project.compiled_assets.each do |asset_file|
        destination = @project.build_path.join(asset_file)
        asset = @sprockets.find_asset(asset_file)

        if !asset.nil?
          puts "Compiling #{ asset.logical_path } ..."
          asset.write_to(destination)
        end

        # Catch any sprockets errors and continue the process
        begin
        # FileUtils.mkdir_p(File.dirname(destination)) unless File.directory?(File.dirname(destination))
        rescue Exception => e
          @task.say "Error while building #{asset.last}:"
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

      # Copy the images directory over
      FileUtils.cp_r(@project.images_path, @project.build_path)

      # Check for screenshot and move it into main build directory
      Dir.glob(File.join(@project.build_path, 'images', '*')).each do |filename|
        if filename.index(/screenshot\.(png|jpg|jpeg|gif)/)
          FileUtils.mv(filename, @project.build_path + File::SEPARATOR )
        end
      end
    end

    private

    def copy_paths_with_erb(paths, source_dir, destination_dir)
      paths.each do |path|
        # Remove source directory from full file path to get the relative path
        relative_path = path.gsub(source_dir.to_s, '')

        destination = File.join(destination_dir.to_s, relative_path)

        if destination.end_with?('.erb')
          # Remove the .erb extension if the path was an erb file
          destination = destination.slice(0..-5)
          # And process it as an erb
          write_erb(path, destination)
        else
          # Otherwise, we simply move the file over
          FileUtils.mkdir_p(destination) if File.directory?(path)
          FileUtils.cp path, destination unless File.directory?(path)
        end
      end
    end

    def init_sprockets
      @sprockets = Sprockets::Environment.new

      ['javascripts', 'stylesheets'].each do |dir|
        @sprockets.append_path File.join(@assets_path, dir)
      end

      # Passing the @project instance variable to the Sprockets::Context instance
      # used for processing the asset ERB files. Ruby meta-programming, FTW.
      @sprockets.context_class.instance_exec(@project) do |project|
        define_method :config do
          project.config
        end
      end
    end

    protected

    # Write an .erb from source to destination, catching and reporting errors along the way
    def write_erb(source, destination)
      begin
        @task.shell.mute do
          @task.create_file(destination) do
            @project.parse_erb(source)
          end
        end
      rescue Exception => e
        @task.say "Error while building #{File.basename(source)}:"
        @task.say e.message + "\n", Thor::Shell::Color::RED
        exit
     end
    end
  end
end

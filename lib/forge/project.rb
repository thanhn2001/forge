require 'pathname'
require 'compass'

module Forge
  class Project

    DEFAULT_COMPILED_ASSETS = %w(style.css theme.js admin.js)

    class << self
      def create(root, config, task)
        root = File.expand_path(root)

        project = self.new(root, task, config)
        Generator.run(project)

        project
      end
    end

    attr_accessor :root, :config, :task
    attr_accessor :compiled_assets

    def initialize(root, task, config={}, config_file=nil)
      @root        = Pathname.new(File.expand_path(root))
      @config      = config || {}
      @task        = task
      @config_file = config_file

      @compiled_assets = DEFAULT_COMPILED_ASSETS.dup

      load_config! if @config.empty?
    end

    def assets_path
      @assets_path ||= Pathname.new(source_path.join('assets'))
    end

    def stylesheets_path
      assets_path.join('stylesheets')
    end

    def images_path
      assets_path.join('images')
    end

    def javascripts_path
      assets_path.join('javascripts')
    end

    def build_path
      @build_path ||= root.join('.forge', 'build')
    end

    def source_path
      @source_path ||= root.join('source')
    end

    def package_path
      File.join(self.root, 'package')
    end

    def templates_path
      source_path.join('templates')
    end

    def functions_path
      source_path.join('functions')
    end

    def includes_path
      source_path.join('includes')
    end

    def config_file
      @config_file ||= root.join('config.rb')
    end

    def global_config_file
      @global_config_file ||= File.join(ENV['HOME'], '.forge', 'config.rb')
    end

    # Create a symlink from source to the project build dir
    def link(source)
      source = File.expand_path(source)

      unless File.directory?(File.dirname(source))
        raise Forge::LinkSourceDirNotFound
      end

      @task.link_file build_path, source
    end

    def theme_id
      File.basename(self.root).gsub(/\W/, '_')
    end

    def load_config!
      config = {}

      # Check for config.rb
      if File.exists?(self.config_file)
        config.merge!(load_ruby_config(self.config_file))
      else
        raise Error, "Could not find the config file, are you sure you're in a
        forge project directory?"
      end

      @config = config
    end

    def get_binding
      binding
    end

    def parse_erb(file)
      ERB.new(::File.binread(file), nil, '-', '@output_buffer').result(binding)
    end

    private

    def load_ruby_config(file)
      config = {}

      begin
        instance_eval(File.read(file))
      rescue Exception => e
        @task.say "Error while evaluating config file:"
        @task.say e.message, Thor::Shell::Color::RED
      end

      return config
    end

  end
end

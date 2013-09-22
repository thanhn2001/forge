require 'ostruct'
require 'pathname'
require 'sprockets'
require 'sprockets-sass'
require 'compass'

module Xerox
  class Project

    DEFAULT_ASSETS = %w(style.css theme.js admin.js)

    ASSET_MATCHER = lambda do |filename, path|
      # By default, we include everything in the source/assets folder that is
      # not prefixed with a `_` (i.e. a partial or import). This is,
      # effectively, the Middleman approach.
      #
      # If we wanted to look more like Rails, we'd do that without the
      # underscore prefixed exclusion, but instead exclude everything
      # that was not a .js or .css file. Like this:
      #
      # && %w[.js .css].include?(File.extname(filename))
      path =~ /source\/assets/ && filename !~ /^_|\/_/
    end

    class << self
      # Create a new Xerox project
      #
      # @param [Pathname|String] root The project root
      # @param [Hash] options
      # @param [Xerox::CLI] task
      #
      # @return [Xerox::Project] The new project
      def create(root, options, task)
        project = self.new(root, options, task)
        Generator.run(project)
        project
      end
    end

    attr_reader :assets, :config, :root, :task

    # @param [Pathname|String] root The project root
    # @param [Hash] options
    # @param [Xerox::CLI] task
    #
    # @return [Xerox::Project] The new project
    def initialize(root, options = {}, task = nil)
      @root   = Pathname.new File.expand_path(root)
      @task   = task

      @config = Config.new(options)
      @config.id ||= File.basename(root).downcase.gsub(/\W/, '_')
      @config.assets = OpenStruct.new(precompile: DEFAULT_ASSETS.dup)
      @config.assets.precompile << ASSET_MATCHER

      load_config! if config_file.exist?

      @assets = Sprockets::Environment.new
      @assets.append_path javascripts_path
      @assets.append_path stylesheets_path
      @assets.append_path images_path
      @assets.append_path fonts_path
    end

    def id
      config.id
    end
    # @depreciated Backwards compatibility. Just use `id` going forward.
    alias_method :theme_id, :id

    # @return [Pathname]
    def assets_path
      @assets_path ||= source_path.join('assets')
    end

    # @return [Pathname]
    def stylesheets_path
      assets_path.join('stylesheets')
    end

    # @return [Pathname]
    def images_path
      assets_path.join('images')
    end

    # @return [Pathname]
    def javascripts_path
      assets_path.join('javascripts')
    end

    # @return [Pathname]
    def fonts_path
      assets_path.join('fonts')
    end

    # @return [Pathname]
    def build_path
      @build_path ||= root.join('.xerox', 'build')
    end

    # @return [Pathname]
    def source_path
      @source_path ||= root.join('source')
    end

    # @return [Pathname]
    def templates_path
      source_path.join('templates')
    end

    # @return [Pathname]
    def functions_path
      source_path.join('functions')
    end

    # @return [Pathname]
    def includes_path
      source_path.join('includes')
    end

    # @return [Pathname]
    def config_file
      @config_file ||= root.join('config.rb')
    end

    # Create a symlink from source to the project build dir
    def link(source)
      source = File.expand_path(source)

      unless File.directory?(File.dirname(source))
        raise Xerox::LinkSourceDirNotFound
      end

      @task.link_file build_path, source
    end

    def get_binding
      binding
    end

    def parse_erb(file)
      ERB.new(::File.binread(file), nil, '-', '@output_buffer').result(binding)
    end

    private

    def load_config!
      instance_eval(File.read(config_file))
    end

  end
end

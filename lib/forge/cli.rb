require 'thor'

module Forge
  class CLI < Thor
    include Thor::Actions

    def self.source_root
      Forge.root.join('layouts').to_s
    end

    register(Generator, 'create', 'create LOCATION', 'Creates a Forge project')

    desc "link PATH", "Create a symbolic link to the compilation directory"
    long_desc "This command will symlink the compiled version of the theme to the specified path.\n\n"+
      "To compile the theme use the `forge watch` command"
    def link(path)
      project = Forge::Project.new('.', self)

      FileUtils.mkdir_p project.build_path unless File.directory?(project.build_path)

      do_link(project, path)
    end

    desc "watch", "Start watch process"
    long_desc "Watches the source directory in your project for changes, and reflects those changes in a compile folder"
    def watch
      project = Forge::Project.new('.', nil, self)
      guard = Forge::Guard.new(project, self)
      guard.start!
    end

    desc "build DIRECTORY", "Build your theme into specified directory"
    option :clean, type: :boolean
    def build(dir = 'build')
      project = Forge::Project.new('.', nil, self)

      builder = Builder.new(project)
      builder.build

      if options[:clean]
        Dir.glob(File.join(dir, '**', '*')).each do |file|
          shell.mute { remove_file(file) }
        end
      end

      directory(project.build_path, dir)
    end

    protected

    def do_link(project, path)
      begin
        project.link(path)
      rescue LinkSourceDirNotFound
        say_status :error, "The path #{File.dirname(path)} does not exist", :red
        exit 2
      rescue Errno::EEXIST
        say_status :error, "The path #{path} already exsts", :red
        exit 2
      end
    end
  end
end

require 'thor/group'

module Forge
  class Generator < Thor::Group
    include Thor::Actions

    argument :location, type: :string, desc: 'The directory to create the project in'
    class_option :layout, default: 'default', desc: 'The layout to use for the new project'
    desc 'Creates a new Forge project'

    def theme_id
      File.basename(location)
    end

    def self.source_root
      File.expand_path(File.join(Forge::ROOT, 'layouts'))
    end

    def create!
      empty_directory location
      template 'shared/Gemfile.tt', File.join(location, 'Gemfile')
      template 'shared/config.tt', File.join(location, 'config.rb')
      directory "#{ options[:layout] }/", File.join(location, 'source')
    end

  end
end

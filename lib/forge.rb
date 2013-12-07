require 'forge/error'
require 'forge/version'
require 'pathname'

module Forge

  def self.root
    @root ||= Pathname.new File.expand_path(File.join(File.dirname(__FILE__), '..'))
  end

  autoload :Builder,   'forge/builder'
  autoload :Config,    'forge/config'
  autoload :CLI,       'forge/cli'
  autoload :Generator, 'forge/generator'
  autoload :Guard,     'forge/guard'
  autoload :Project,   'forge/project'
end

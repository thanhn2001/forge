require 'forge/error'
require 'forge/version'

module Forge
  ROOT = File.expand_path(File.join(File.dirname(__FILE__), '..'))
  autoload :Builder,   'forge/builder'
  autoload :Config,    'forge/config'
  autoload :CLI,       'forge/cli'
  autoload :Generator, 'forge/generator'
  autoload :Guard,     'forge/guard'
  autoload :Project,   'forge/project'
end

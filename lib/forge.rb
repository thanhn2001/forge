require 'forge/error'

module Forge
  ROOT = File.expand_path(File.join(File.dirname(__FILE__), '..'))
  autoload :Builder,   'forge/builder'
  autoload :CLI,       'forge/cli'
  autoload :Generator, 'forge/generator'
  autoload :Guard,     'forge/guard'
  autoload :Project,   'forge/project'
end

require 'xerox/error'

module Xerox
  ROOT = File.expand_path(File.join(File.dirname(__FILE__), '..'))
  autoload :Builder,   'xerox/builder'
  autoload :Config,    'xerox/config'
  autoload :CLI,       'xerox/cli'
  autoload :Generator, 'xerox/generator'
  autoload :Guard,     'xerox/guard'
  autoload :Project,   'xerox/project'
end

# -*- encoding: utf-8 -*-
require File.expand_path('../lib/forge/version', __FILE__)

Gem::Specification.new do |gem|
  gem.name          = "forge"
  gem.authors       = ["Andy Adams", "Drew Strojny", "Matt Button", "Jason Webster"]
  gem.email         = ["jason@metalabdesign.com"]
  gem.license       = "MIT"
  gem.summary       = "A tool for developing WordPress themes"
  gem.description   = "A toolkit for bootstrapping and developing WordPress themes."
  gem.homepage      = "https://github.com/jasonwebster/forge"

  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {spec,features}/*`.split("\n")
  gem.require_paths = ["lib"]
  gem.version       = Forge::VERSION

  gem.add_dependency "bundler",      "~> 1.1"
  gem.add_dependency "coffee-script"
  gem.add_dependency "compass",      ">= 0.12"
  gem.add_dependency "json",         "~> 1.8.0"
  gem.add_dependency "listen",       "~> 1.3"
  gem.add_dependency "rack",         ">= 1.4.5"
  gem.add_dependency "rake"
  gem.add_dependency "rb-fsevent",   "~> 0.9.1"
  gem.add_dependency "sass",         ">= 3.2.0"
  gem.add_dependency "sprockets"
  gem.add_dependency "sprockets-sass"
  gem.add_dependency "thor"

  gem.add_development_dependency "aruba"
  gem.add_development_dependency "cucumber"
  gem.add_development_dependency "rspec"
end

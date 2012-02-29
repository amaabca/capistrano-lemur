# -*- encoding: utf-8 -*-
require File.expand_path('../lib/capistrano-lemur/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Jordan Babe"]
  gem.email         = ["jorbabe@gmail.com"]
  gem.description   = %q{Recipes for deploying a LEMUR (Linux/Nginx/Mysql/Unicorn/Rails) stack. Some of it is pulled from an existing application}
  gem.summary       = %q{Collection of Capistrano recipes for deploying a LEMUR (Linux/Nginx/Mysql/Unicorn/Rails) stack}
  gem.homepage      = "https://github.com/jbabe/capistrano-lemur"

  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.name          = "capistrano-lemur"
  gem.require_paths = ["lib"]
  gem.version       = Capistrano::Lemur::VERSION
  
  gem.add_dependency "capistrano", "~> 2.11.2"
  
end

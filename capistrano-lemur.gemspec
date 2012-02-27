# -*- encoding: utf-8 -*-
require File.expand_path('../lib/capistrano-lemur/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Jordan Babe"]
  gem.email         = ["jorbabe@gmail.com"]
  gem.description   = %q{Collection of recipes for deploying a LEMUR (Linux/Nginx/Mysql/Ubuntu/Rails) stack}
  gem.summary       = %q{Collection of recipes for deploying a LEMUR (Linux/Nginx/Mysql/Ubuntu/Rails) stack}
  gem.homepage      = ""

  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.name          = "capistrano-lemur"
  gem.require_paths = ["lib"]
  gem.version       = Capistrano::Lemur::VERSION
end

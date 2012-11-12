# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'fontcustom/version'

Gem::Specification.new do |gem|
  gem.name          = "fontcustom"
  gem.version       = Fontcustom::VERSION
  gem.authors       = ["Yifei Zhang", "Joshua Gross"]
  gem.email         = ["yz@yifei.co", "joshua@gross.is"]
  gem.summary       = %q{Generate custom icon webfonts from the comfort of the command line.}
  gem.description   = %q{Transforms EPS and SVG vectors into icon webfonts. Generates Bootstrap compatible CSS for easy inclusion in your projects.}
  gem.homepage      = "http://endtwist.github.com/fontcustom/"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency 'json'
  gem.add_dependency 'thor'

  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'bundler'
  gem.add_development_dependency 'rspec'
  gem.add_development_dependency 'fakefs'
  gem.add_development_dependency 'spork'
  gem.add_development_dependency 'guard-spork'
  gem.add_development_dependency 'guard-rspec'
  gem.add_development_dependency 'rb-fsevent', '~> 0.9.1'
end

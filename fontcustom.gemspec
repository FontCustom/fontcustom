# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'fontcustom/version'

Gem::Specification.new do |gem|
  gem.name          = 'fontcustom'
  gem.version       = Fontcustom::VERSION
  gem.authors       = ['Kai Zau', 'Joshua Gross']
  gem.email         = ['kai@kaizau.com', 'joshua@gross.is']
  gem.summary       = 'Generate icon fonts from the command line.'
  gem.description   = 'Font Custom makes using vector icons easy. Generate icon fonts and supporting templates (e.g. @font-face CSS) from a collection of SVGs.'
  gem.homepage      = 'http://fontcustom.com'
  gem.post_install_message = '>> Thanks for installing Font Custom! Please ensure that fontforge is installed before compiling any icons. Visit <http://fontcustom.com> for instructions.'

  gem.files         = `git ls-files`.split($INPUT_RECORD_SEPARATOR)
  gem.executables   = gem.files.grep(%r{^bin/}).map { |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ['lib']

  gem.add_dependency 'json', '~>1.4'
  gem.add_dependency 'thor', '~>0.14'
  gem.add_dependency 'listen', '>=1.0', '<3.0'

  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'bundler'
  gem.add_development_dependency 'rspec', '~>3.1.0'
end

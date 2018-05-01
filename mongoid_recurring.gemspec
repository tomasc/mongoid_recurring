# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'mongoid_recurring/version'

Gem::Specification.new do |spec|
  spec.name          = 'mongoid_recurring'
  spec.version       = MongoidRecurring::VERSION
  spec.authors       = ['Tomas Celizna']
  spec.email         = ['tomas.celizna@gmail.com']

  spec.summary       = 'Recurring date time fields for Mongoid models.'
  spec.homepage      = 'https://github.com/tomasc/mongoid_recurring'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'activesupport', '> 3.0'
  spec.add_dependency 'ice_cube'
  spec.add_dependency 'mongoid', '>= 5.1', '<= 7'
  spec.add_dependency 'mongoid_ice_cube_extension', '>= 0.1.1'

  spec.add_development_dependency 'bundler', '~> 1.6'
  spec.add_development_dependency 'coveralls'
  spec.add_development_dependency 'database_cleaner'
  spec.add_development_dependency 'guard'
  spec.add_development_dependency 'guard-minitest'
  spec.add_development_dependency 'minitest'
  spec.add_development_dependency 'rake', '~> 10.0'
end

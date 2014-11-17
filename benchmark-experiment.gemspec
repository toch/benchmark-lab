# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'benchmark/experiment/version'

Gem::Specification.new do |spec|
  spec.name          = 'benchmark-experiment'
  spec.version       = Benchmark::Experiment::VERSION
  spec.authors       = ['Christophe Philemotte']
  spec.email         = ['christophe.philemotte@8thcolor.com']
  spec.summary       = %q{Run Real Experiment and Calculate Non-Parametric Statistics.}
  spec.description   = %q{Run Real Experiment and Calculate Non-Parametric Statistics.}
  spec.homepage      = 'https://github.com/toch/benchmark-experiment'
  spec.license       = 'GPLv3'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.6'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'minitest', '4.5.0'
  spec.add_development_dependency 'turn', '~> 0.9'
  spec.add_runtime_dependency 'distribution'
end
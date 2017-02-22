# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'wikisnakker/version'

Gem::Specification.new do |spec|
  spec.name          = 'wikisnakker'
  spec.version       = Wikisnakker::VERSION
  spec.authors       = ['Tony Bowden']
  spec.email         = ['tony@mysociety.org']
  spec.summary       = 'Fetch Wikidata.'
  spec.description   = 'Turn Wikidata items into Ruby structures.'
  spec.homepage      = 'https://github.com/everypolitician/wikisnakker'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'require_all'
  spec.add_dependency 'yajl-ruby'

  spec.add_development_dependency 'bundler', '~> 1.6'
  spec.add_development_dependency 'rake', '~> 10.4.2'
  spec.add_development_dependency 'pry', '~> 0.10.3'
  spec.add_development_dependency 'minitest', '~> 5.8.2'
  spec.add_development_dependency 'rubocop', '~> 0.34.2'
  spec.add_development_dependency 'vcr', '~> 3.0.3'
  spec.add_development_dependency 'webmock', '~> 2.3.2'
  spec.add_development_dependency 'minitest-around', '~> 0.3.2'
end

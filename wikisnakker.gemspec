# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'wikisnakker/version'

Gem::Specification.new do |spec|
  spec.name          = "wikisnakker"
  spec.version       = Wikisnakker::VERSION
  spec.authors       = ["Tony Bowden"]
  spec.email         = ["tony@mysociety.org"]
  spec.summary       = %q{Fetch Wikidata.}
  spec.description   = %q{Turn Wikidata items into Ruby structures.}
  spec.homepage      = "https://github.com/everypolitician/wikisnakker"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency 'open-uri-cached'
  spec.add_dependency 'colorize'

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "pry"
end

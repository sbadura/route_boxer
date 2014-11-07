# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'route_boxer/version'

Gem::Specification.new do |spec|
  spec.name          = "route_boxer"
  spec.version       = RouteBoxer::VERSION
  spec.authors       = ["Sebastian Badura"]
  spec.email         = ["badura.sebastian@gmail.com"]
  spec.summary       = %q{Ruby implementation fo RouteBoxer}
  spec.description   = %q{Ruby implementation fo RouteBoxer}
  spec.homepage      = "http://www.github.com/sbadura/route_boxer"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"
end

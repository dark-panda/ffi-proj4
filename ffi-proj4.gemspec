# -*- encoding: utf-8 -*-

require File.expand_path('../lib/ffi-proj4/version', __FILE__)

Gem::Specification.new do |s|
  s.name = "ffi-proj4"
  s.version = Proj4::VERSION

  s.required_rubygems_version = Gem::Requirement.new("> 1.3.1") if s.respond_to? :required_rubygems_version=
  s.authors = ["J Smith"]
  s.description = "An ffi wrapper for the PROJ.4 Cartographic Projections library."
  s.summary = s.description
  s.email = "dark.panda@gmail.com"
  s.files = `git ls-files`.split($\)
  s.executables = s.files.grep(%r{^bin/}).map { |f| File.basename(f) }
  s.test_files = s.files.grep(%r{^(test|spec|features)/})
  s.homepage = "http://github.com/dark-panda/ffi-proj4"
  s.require_paths = ["lib"]

  s.add_dependency("ffi", ["~> 1.0.0"])
  s.add_dependency("rdoc")
  s.add_dependency("rake", ["~> 0.9"])
end


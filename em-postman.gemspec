# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "em-postman/version"

Gem::Specification.new do |s|
  s.name        = "em-postman"
  s.version     = EventMachine::Postman::VERSION
  s.authors     = ["Vivien Schilis"]
  s.email       = ["vivien.schilis@gmail.com"]
  s.homepage    = "http://github.com/vivienschilis/em-postman"
  s.summary     = %q{EventMachine pub/sub using Redis list, resilient to failure}
  s.description = %q{EventMachine pub/sub using Redis list, resilient to failure}

  s.rubyforge_project = "em-postman"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency "em-hiredis"
  s.add_dependency "multi_json"
  s.add_dependency "yajl-ruby"

  s.add_development_dependency "em-spec"
  s.add_development_dependency "rspec"
end

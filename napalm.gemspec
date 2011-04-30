# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "napalm/version"

Gem::Specification.new do |s|
  s.name        = "napalm"
  s.version     = Napalm::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Mike Lewis"]
  s.email       = ["ft.mikelewis@gmail.com"]
  s.homepage    = ""
  s.summary     = %q{Simple Message Queue}
  s.description = %q{Simple Message Queue}

  s.rubyforge_project = "napalm"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
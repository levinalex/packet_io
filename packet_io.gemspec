# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require 'packet_io'

Gem::Specification.new do |s|
  s.name = %q{packet_io}
  s.version = PacketIO::VERSION

  s.authors = ["Levin Alexander"]
  s.description = %q{}
  s.email = %q{mail@levinalex.net}

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }

  s.homepage = %q{http://github.com/levinalex/packet_io}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.summary = %q{define packet based protocols in a declarative fashion}

  s.add_development_dependency("shoulda", ["~> 2.11.3"])
  s.add_development_dependency("mocha", ["~> 0.9.12"])
  s.add_development_dependency("yard", ["~> 0.7.1"])
  s.add_development_dependency("cucumber", ["~> 0.10.3"])
end

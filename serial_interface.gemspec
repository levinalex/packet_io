Gem::Specification.new do |s|
  s.name = %q{serial_interface}
  s.version = "0.2.3"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Levin Alexander"]
  s.date = %q{2008-10-12}
  s.description = %q{serial_interface intends to be a small library that makes it easy to define packet based protocols over a serial link (RS232) in a declarative fashion.}
  s.email = ["mail@levinalex.net"]
  s.extra_rdoc_files = ["History.txt", "Manifest.txt", "README.txt"]
  s.files = ["History.txt", "Manifest.txt", "README.txt", "Rakefile", "lib/protocol/rca2006.rb", "lib/serial_interface.rb", "lib/serial_packet.rb", "serial_interface.gemspec", "test/test_serial_interface.rb", "test/test_serial_io.rb", "test/test_serial_packets.rb"]
  s.has_rdoc = true
  s.homepage = %q{http://levinalex.net/src/serial_interface}
  s.rdoc_options = ["--main", "README.txt"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{serial_interface}
  s.rubygems_version = %q{1.2.0}
  s.summary = %q{abstracts protocols on a serial link}
  s.test_files = ["test/test_serial_interface.rb", "test/test_serial_io.rb", "test/test_serial_packets.rb"]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if current_version >= 3 then
      s.add_runtime_dependency(%q<traits>, [">= 0"])
      s.add_development_dependency(%q<hoe>, [">= 1.8.0"])
    else
      s.add_dependency(%q<traits>, [">= 0"])
      s.add_dependency(%q<hoe>, [">= 1.8.0"])
    end
  else
    s.add_dependency(%q<traits>, [">= 0"])
    s.add_dependency(%q<hoe>, [">= 1.8.0"])
  end
end

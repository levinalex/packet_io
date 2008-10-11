require 'rubygems'
require 'hoe'
require 'spec/rake/spectask'

require './lib/serial_interface.rb'

Hoe.new('serial_interface', SerialInterface::VERSION) do |p|
  p.rubyforge_name = 'serial_interface'
  p.summary = "abstracts protocols on a serial link"
  p.changes = p.paragraphs_of('History.txt', 0..1).join("\n\n")
  p.url = "http://levinalex.net/src/serial_interface"
  p.developer('Levin Alexander', 'mail@levinalex.net')

  p.extra_deps = ["traits"]
end

task :cultivate do
  system "touch Manifest.txt; rake check_manifest | grep -v \"(in \" | patch"
  system "rake debug_gem | grep -v \"(in \" > `basename \\`pwd\\``.gemspec"
end

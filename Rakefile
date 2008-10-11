require 'rubygems'
require 'hoe'
require 'spec/rake/spectask'

require './lib/serial_interface.rb'

Hoe.new('serial_interface', SerialInterface::VERSION) do |p|
  p.rubyforge_name = 'serial_interface'
  p.summary = "wrapper for serial port on unix"
  p.summary = "abstracts protocols on the serial port"
  p.changes = p.paragraphs_of('History.txt', 0..1).join("\n\n")
  p.developer('Levin Alexander', 'mail@levinalex.net')

  p.extra_deps = ["traits", "anyforge"]
end

# Rake.application.instance_eval { @tasks["test"] = nil }

#Spec::Rake::SpecTask.new do |t|
#  t.warning = true
#  t.spec_opts = %w(-c -f specdoc)
#end
#task :test => :spec

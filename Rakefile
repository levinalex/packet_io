$LOAD_PATH.unshift './lib'

require 'bundler'
Bundler::GemHelper.install_tasks

require 'packet_io'

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'test'
end

require 'yard'
YARD::Rake::YardocTask.new

task :doc => :yard
task :default => [:test]


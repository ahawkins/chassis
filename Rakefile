require "bundler/gem_tasks"

require 'rake/testtask'
require 'stringio'

def capture_stdout
  out = StringIO.new
  $stdout = out
  yield
  return out
ensure
  $stdout = STDOUT
end

desc 'Run examples'
task :examples do
  root = File.dirname __FILE__
  Dir["#{root}/examples/*.rb"].each do |example|
    capture_stdout do
      require example
    end
  end
end

namespace :test do
  Rake::TestTask.new(:all) do |t|
    t.pattern = 'test/**/*_test.rb'
  end
end

task test: ['test:all', 'examples']

task default: :test

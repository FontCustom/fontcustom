require "bundler/gem_tasks"
require 'rake/testtask'

Rake::TestTask.new do |t|
  t.libs = t.libs + ['lib/fontcustom', 'spec', 'spec/fixtures']
  t.test_files = FileList['spec/fontcustom/*_spec.rb']
  t.verbose = true
end

task :default => :test

require "rubygems"
require "bundler/setup"
require "bundler/gem_tasks"
require "rake/testtask"
require "appraisal"
require 'rdoc/task'

Rake::TestTask.new do |t|
  t.libs.concat %w(console_utils spec)
  t.pattern = "spec/**/*_spec.rb"
end

desc 'Start the Rails console'
task :console => :development_env do
  require 'rails/commands/console'
  Rails::Console.start(Rails.application)
end

task :development_env do
  ENV['RAILS_ENV'] = 'development'
  require File.expand_path('../spec/config/environment', __FILE__)
  Dir.chdir(Rails.application.root)
end

RDoc::Task.new do |rdoc|
  rdoc.main = "README.md"
  rdoc.rdoc_dir = "doc"
  rdoc.rdoc_files.include("README.md", "lib/**/*.rb")
  rdoc.options = ["--no-dcov", "--visibility=protected"]
end

# Must invoke indirectly, using `rake appraisal`.
task :default => [:test]
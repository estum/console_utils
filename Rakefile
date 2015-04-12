require "bundler/gem_tasks"

require 'rdoc/task'

RDoc::Task.new do |rdoc|
  rdoc.main = "README.md"
  rdoc.rdoc_dir = "doc"
  rdoc.rdoc_files.include("README.md", "lib/**/*.rb")
  rdoc.options = ["--no-dcov", "--visibility=protected"]
end
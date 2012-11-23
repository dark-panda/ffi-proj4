
# -*- ruby -*-

require 'rubygems'
require 'rubygems/package_task'
require 'rake/testtask'
require 'rdoc/task'
require 'bundler/gem_tasks'

$:.push File.expand_path(File.dirname(__FILE__), 'lib')

version = Proj4::VERSION

desc 'Test Proj4 interface'
Rake::TestTask.new(:test) do |t|
  t.test_files = FileList['test/**/*_tests.rb']
  t.verbose = !!ENV['VERBOSE_TESTS']
  t.warning = !!ENV['WARNINGS']
end

desc 'Build docs'
Rake::RDocTask.new do |t|
  t.title ="ffi-proj4 #{version}"
  t.main = 'README.rdoc'
  t.rdoc_dir = 'doc'
  t.rdoc_files.include('MIT-LICENSE', 'lib/**/*.rb')
end

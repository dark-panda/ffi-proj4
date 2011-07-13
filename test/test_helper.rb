
require 'rubygems'
require 'test/unit'

if ENV['USE_BINARY_PROJ4']
  require 'proj4_ruby'
else
  require File.join(File.dirname(__FILE__), %w{ .. lib ffi-proj4 })
end

puts "Ruby version #{RUBY_VERSION} - #{RbConfig::CONFIG['RUBY_INSTALL_NAME']}"
puts "ffi-proj4 version #{Proj4::VERSION}"
puts "PROJ version #{Proj4.version}"
if defined?(Proj4::FFIProj4)
  puts "Using #{Array(Proj4::FFIProj4.proj4_library_path).join(', ')}"
end
puts "Using PROJ_LIB #{Proj4.proj_lib}"

module TestHelper
  TOLERANCE = 0.00000001

  def self.included(base)
    base.class_eval do
    end
  end

  def setup
  end
end

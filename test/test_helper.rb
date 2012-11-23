
require 'rubygems'
require 'minitest/autorun'

if RUBY_VERSION >= '1.9'
  require 'minitest/reporters'
end

if ENV['USE_BINARY_PROJ4']
  require 'proj4_ruby'
else
  require File.join(File.dirname(__FILE__), %w{ .. lib ffi-proj4 })
end

Proj4.proj_lib = File.join(File.dirname(__FILE__), %w{ .. data }) if Proj4.respond_to?(:proj_lib)

puts "Ruby version #{RUBY_VERSION} - #{RbConfig::CONFIG['RUBY_INSTALL_NAME']}"
puts "ffi-proj4 version #{Proj4::VERSION}"
puts "PROJ version #{Proj4.version}"
if defined?(Proj4::FFIProj4)
  puts "Using #{Array(Proj4::FFIProj4.proj4_library_path).join(', ')}"
end
puts "Using PROJ_LIB #{Proj4.proj_lib}"

module TestHelper
  TOLERANCE = 0.000001

  PROJ_WGS84 = Proj4::Projection.new('init=epsg:4326')
  PROJ_GK = Proj4::Projection.new('init=epsg:31467')
  PROJ_CONAKRY = Proj4::Projection.new('init=epsg:31528')
  PROJ_ORTEL = Proj4::Projection.new([ 'proj=ortel', 'lon_0=90w' ])

  PROJ_WGS84_HASH = {
    :init => 'epsg:4326',
    :proj => 'longlat',
    :datum => 'WGS84',
    :no_defs => true,
    :ellps => 'WGS84',
    :towgs84 => '0,0,0'
  }

  PROJ_GK_HASH = {
    :init => 'epsg:31467',
    :proj => 'tmerc',
    :lat_0 => '0',
    :lon_0 => '9',
    :k => '1',
    :x_0 => '3500000',
    :y_0 => '0',
    :datum => 'potsdam',
    :units => 'm',
    :no_defs => true,
    :ellps => 'bessel',
    :towgs84 => '598.1,73.7,418.2,0.202,0.045,-2.455,6.7'
  }

  PROJ_CONAKRY_HASH = {
    :init => 'epsg:31528',
    :proj => 'utm',
    :zone => '28',
    :a => '6378249.2',
    :b => '6356515',
    :towgs84 => '-23,259,-9,0,0,0,0',
    :units => 'm',
    :no_defs => true
  }

  PROJ_ORTEL_HASH = {
    :proj => 'ortel',
    :lon_0 => '90w',
    :ellps => 'WGS84'
  }
end

if RUBY_VERSION >= '1.9'
  MiniTest::Reporters.use!(MiniTest::Reporters::SpecReporter.new)
end


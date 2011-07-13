
require 'rubygems'
require 'ffi'
require 'rbconfig'

#ENV['PROJ_LIB'] = File.join(File.dirname(__FILE__), %w{ .. data }) unless ENV['PROJ_LIB']
#p ENV['PROJ_LIB']

module Proj4
  PROJ4_BASE = File.join(File.dirname(__FILE__), 'ffi-proj4')

  autoload :Projection,
    File.join(PROJ4_BASE, 'projection')
  autoload :ProjXY,
    File.join(PROJ4_BASE, 'projxy')
  autoload :Tools,
    File.join(PROJ4_BASE, 'tools')
  autoload :Point,
    File.join(PROJ4_BASE, 'point')

  module FFIProj4
    def self.proj4_library_path
      return @proj4_library_paths if @proj4_library_paths

      paths = if ENV['PROJ4_LIBRARY_PATH']
        [ ENV['PROJ4_LIBRARY_PATH'] ]
      else
        [ '/usr/local/{lib64,lib}', '/opt/local/{lib64,lib}', '/usr/{lib64,lib}' ]
      end

      lib = if [
        Config::CONFIG['arch'],
        Config::CONFIG['host_os']
      ].detect { |c| c =~ /darwin/ }
        'libproj.dylib'
      else
        'libproj.so'
      end

      @proj4_library_path = Dir.glob(paths.collect { |path|
          "#{path}/#{lib}"
      }).first
    end

    extend ::FFI::Library

    ffi_lib(*proj4_library_path)

    FFI_LAYOUT = {
      :pj_get_release => [
        :string
      ],

      :pj_transform => [
        :int, :pointer, :pointer, :long, :int, :pointer, :pointer, :pointer
      ],

      :pj_init_plus => [
        :pointer, :string
      ],

      :pj_free => [
        :void, :pointer
      ],

      :pj_is_latlong => [
        :int, :pointer
      ],

      :pj_is_geocent => [
        :int, :pointer
      ],

      :pj_get_def => [
        :string, :pointer, :int
      ],

      :pj_latlong_from_proj => [
        :pointer, :pointer
      ],

      :pj_set_finder => [
        :void, callback([ :string ], :string)
      ],

      :pj_set_searchpath => [
        :void, :int, :pointer
      ],

      :pj_deallocate_grids => [
        :void
      ],

      :pj_strerrno => [
        :string, :int
      ],

      :pj_get_errno_ref => [
        :pointer
      ],

      :pj_fwd => [
        Proj4::ProjXY.by_value, Proj4::ProjXY.by_value, :pointer
      ],

      :pj_inv => [
        Proj4::ProjXY.by_value, Proj4::ProjXY.by_value, :pointer
      ],

      :pj_transform => [
        :int, :pointer, :pointer, :long, :int, :pointer, :pointer, :pointer
      ],

      :pj_datum_transform => [
        :int, :pointer, :pointer, :long, :int, :pointer, :pointer, :pointer
      ],

      :setenv => [
        :int, :string, :string, :int
      ]
    }

    FFI_LAYOUT.each do |fun, ary|
      ret = ary.shift
      begin
        self.class_eval do
          attach_function(fun, ary, ret)
        end
      rescue FFI::NotFoundError
        # that's okay
      end
    end
  end

  class << self
    attr_reader :proj_lib

    def version
      FFIProj4.pj_get_release
    end

    def proj_lib=(lib)
      @proj_lib = lib
      if RUBY_PLATFORM == 'java'
        FFIProj4.setenv('PROJ_LIB', lib, 1)
      else
        ENV['PROJ_LIB'] = lib
      end
    end
  end

  module Constants
    VERSION = File.read(File.join(PROJ4_BASE, %w{ .. .. VERSION })).strip
    PROJ4_VERSION = if Proj4.version =~ /Rel\. (\d+)\.(\d+)\.(\d+)/
      "#{$1}#{$2}#{$3}".to_f
    end

    RAD_TO_DEG = 57.29577951308232
    DEG_TO_RAD = 0.0174532925199432958
  end

  include Constants

  self.proj_lib = ENV['PROJ_LIB'] || File.join(File.dirname(__FILE__), %w{ .. data })
end

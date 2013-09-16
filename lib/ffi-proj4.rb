
require 'rubygems'
require 'ffi'
require 'rbconfig'
require 'ffi-proj4/version'
require 'ffi-proj4/error'

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
      return @proj4_library_path if defined?(@proj4_library_path)

      lib = if FFI::Platform::IS_WINDOWS
        # For MinGW and the official binaries
        '{libproj-?,proj}.dll'
      else
        "libproj.#{FFI::Platform::LIBSUFFIX}"
      end

      paths = if ENV['PROJ4_LIBRARY_PATH']
        [ ENV['PROJ4_LIBRARY_PATH'] ]
      elsif FFI::Platform::IS_WINDOWS
        ENV['PATH'].split(File::PATH_SEPARATOR)
      else
        [ '/usr/local/{lib64,lib}', '/opt/local/{lib64,lib}', '/usr/{lib64,lib}', '/usr/lib/{x86_64,i386}-linux-gnu' ]
      end

      @proj4_library_path = Dir.glob(paths.collect { |path|
        File.expand_path(File.join(path, lib))
      }).first
    end

    extend ::FFI::Library

    ffi_lib(*proj4_library_path)

    FFI_LAYOUT = {
      :pj_get_release => [
        :string
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
      if RUBY_PLATFORM == 'java' && FFIProj4.respond_to?(:setenv)
        FFIProj4.setenv('PROJ_LIB', lib, 1)
      else
        ENV['PROJ_LIB'] = lib
      end
    end
  end

  module Constants
    PROJ4_VERSION = if Proj4.version =~ /Rel\. (\d+)\.(\d+)\.(\d+)/
      "#{$1}#{$2}#{$3}".to_f
    end

    LIBVERSION = PROJ4_VERSION

    RAD_TO_DEG = 57.29577951308232
    DEG_TO_RAD = 0.0174532925199432958
  end

  include Constants

  self.proj_lib = ENV['PROJ_LIB'] || File.join(File.dirname(__FILE__), %w{ .. data })
end

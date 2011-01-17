
require 'rubygems'
require 'ffi'
require 'rbconfig'

module Proj4
  PROJ4_BASE = File.dirname(__FILE__)

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
        [ '/usr/{lib,lib64}', '/usr/local/{lib,lib64}', '/opt/local/{lib,lib64}' ]
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
    def version
      FFIProj4.pj_get_release
    end
  end

  module Constants
    VERSION = if Proj4.version =~ /Rel\. (\d+)\.(\d+)\.(\d+)/
      "#{$1}#{$2}#{$3}".to_f
    end

    RAD_TO_DEG = 57.29577951308232
    DEG_TO_RAD = 0.0174532925199432958
  end

  ENV['PROJ_LIB'] = File.join(File.dirname(PROJ4_BASE), %w{ data }) unless ENV['PROJ_LIB']

  include Constants
end

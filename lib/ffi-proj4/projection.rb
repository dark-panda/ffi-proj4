
module Proj4
  class ProjectionParseError < RuntimeError; end
  class TransformError < RuntimeError; end

  class Projection
    include Tools

    attr_reader :ptr

    def initialize(arg, auto_free = true)
      args = case arg
        when Array
          arg.collect { |a| a.sub(/^\+/, '') }
        when String
          arg.strip.split(/ /).collect { |a| a.sub(/^\+/, '') }
        when Hash
          arg.collect { |k, v|
            if v.nil?
              k.to_s
            else
              "#{k.to_s.strip}=#{v.to_s.strip}"
            end
          }
        when Proj4::Projection
          arg.definition.strip.split(/ /).collect { |a| a.sub(/^\+/, '') }
        else
          raise ArgumentError.new("Unknown type #{arg.class} for projection definition")
      end

      params = args.collect(&:strip).collect { |a|
        if !(a =~ /^\+/)
          "+#{a}"
        else
          a
        end
      }.join(' ')

      ptr = FFIProj4.pj_init_plus(params)

      if ptr.null?
        errno = FFIProj4.pj_get_errno_ref.read_int
        raise ProjectionParseError.new(FFIProj4.pj_strerrno(errno))
      else
        @ptr = FFI::AutoPointer.new(
          ptr,
          auto_free ? self.class.method(:release) : self.class.method(:no_release)
        )
      end
    end

    def self.no_release(ptr) #:nodoc:
    end

    def self.release(ptr) #:nodoc:
      FFIProj4.pj_free(ptr)
    end

    def lat_long?
      bool_result(FFIProj4.pj_is_latlong(self.ptr))
    end

    def geocentric?
      bool_result(FFIProj4.pj_is_geocent(self.ptr))
    end

    def definition
      @definition ||= FFIProj4.pj_get_def(self.ptr, 0).strip
    end

    def definition_as_hash
      self.definition.split(/ /).inject({}) { |memo, opt|
        memo.tap {
          k, v = opt.split(/=/)
          k.sub!(/^\+/, '')
          v = true if v.nil?
          memo[k.to_sym] = v
        }
      }
    end

    #def to_s
      #"#<Proj4::Projection #{definition}>"
    #end
    #alias :inspect :to_s

    def forward(x, y)
      xy = ProjXY.new(x, y)
      ret = FFIProj4.pj_fwd(xy, self.ptr)
      errno = FFIProj4.pj_get_errno_ref.read_int
      if errno == 0
        Point.new(ret[:x], ret[:y])
      else
        raise TransformError.new(FFIProj4.pj_strerrno(errno))
      end
    end
    alias :forward_deg :forward

    def forward_rad(x, y)
      self.forward(deg_to_rad(x), deg_to_rad(y))
    end

    def inverse(x, y)
      xy = ProjXY.new(x, y)
      ret = FFIProj4.pj_inv(xy, self.ptr)
      errno = FFIProj4.pj_get_errno_ref.read_int
      if errno == 0
        Point.new(ret.x, ret.y)
      else
        raise TransformError.new(FFIProj4.pj_strerrno(errno))
      end
    end
    alias :inverse_deg :inverse

    def inverse_rad(x, y)
      self.inverse(deg_to_rad(x), deg_to_rad(y))
    end

    def transform(proj, x, y, z = nil)
      if !proj.is_a?(Proj4::Projection)
        raise ArgumentError.new("Expected a Proj4::Projection")
      end

      x_ptr = FFI::MemoryPointer.new(:double)
      y_ptr = FFI::MemoryPointer.new(:double)
      z_ptr = FFI::MemoryPointer.new(:double)

      x_ptr.write_double(x)
      y_ptr.write_double(y)
      z_ptr.write_double(z.nil? ? 0 : z)

      result = FFIProj4.pj_transform(self.ptr, proj.ptr, 1, 1, x_ptr, y_ptr, z_ptr)

      if result >= 0 && !bool_result(result)
        Point.new(
          x_ptr.read_double,
          y_ptr.read_double,
          z_ptr.read_double
        )
      else
        raise TransformError.new(FFIProj4.pj_strerrno(result))
      end
    end
    alias :transform_rad :transform

    def transform_deg(proj, x, y, z = nil)
      self.transform(proj, x, y, z).tap { |ret|
        ret.x = rad_to_deg(ret.x)
        ret.y = rad_to_deg(ret.y)
        ret.z = rad_to_deg(ret.z)
      }
    end

    def datum_transform(proj, x, y, z = nil)
      if !proj.is_a?(Proj4::Projection)
        raise ArgumentError.new("Expected a Proj4::Projection")
      end

      x_ptr = FFI::MemoryPointer.new(:double)
      y_ptr = FFI::MemoryPointer.new(:double)
      z_ptr = FFI::MemoryPointer.new(:double) unless z.nil?

      x_ptr.write_double(x)
      y_ptr.write_double(y)
      z_ptr.write_double(z) unless z.nil?

      result = FFIProj4.pj_transform(self.ptr, proj.ptr, 1, 1, x_ptr, y_ptr, z_ptr)

      if result >= 0 && !bool_result(result)
        Point.new(
          x_ptr.read_double,
          y_ptr.read_double,
          z_ptr.read_double
        )
      else
        raise TransformError.new(FFIProj4.pj_strerrno(result))
      end
    end
    alias :datum_transform_rad :datum_transform

    def datum_transform_deg(proj, x, y, z = nil)
      self.datum_transform(proj, x, y, z).tap { |ret|
        ret.x = rad_to_deg(ret.x)
        ret.y = rad_to_deg(ret.y)
        ret.z = rad_to_deg(ret.z)
      }
    end
  end
end

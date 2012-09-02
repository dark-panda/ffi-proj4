
module Proj4
  class ProjectionParseError < RuntimeError; end

  class Projection
    include Tools

    attr_reader :ptr

    def initialize(arg, auto_free = true)
      args = case arg
        when Array
          arg.collect { |a| a.sub(/^\+/, '') }
        when String
          if arg =~ /^(epsg|esri):/i
            [ "+init=#{arg}" ]
          else
            arg.strip.split(/ /).collect { |a| a.sub(/^\+/, '') }
          end
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
        result = FFIProj4.pj_get_errno_ref.read_int
        raise ProjectionParseError.new(FFIProj4.pj_strerrno(result))
      else
        @ptr = FFI::AutoPointer.new(
          ptr,
          self.class.method(:release)
        )
      end

      self.ptr.autorelease = auto_free
    end

    def self.release(ptr) #:nodoc:
      FFIProj4.pj_free(ptr)
    end

    def lat_long?
      bool_result(FFIProj4.pj_is_latlong(self.ptr))
    end
    alias :isLatLong? :lat_long?

    def geocentric?
      bool_result(FFIProj4.pj_is_geocent(self.ptr))
    end
    alias :isGeocent? :geocentric?
    alias :isGeocentric? :geocentric?

    def definition
      @definition ||= FFIProj4.pj_get_def(self.ptr, 0).strip
    end
    alias :getDef :definition

    def to_hash
      @hash ||= self.definition.split(/ /).inject({}) { |memo, opt|
        memo.tap {
          k, v = opt.split('=')
          k.sub!(/^\+/, '')
          v = true if v.nil?
          memo[k.to_sym] = v
        }
      }
    end
    alias :definition_as_hash :to_hash

    def to_s
      "#<Proj4::Projection #{definition}>"
    end
    alias :inspect :to_s

    def forward!(*args)
      xy, point = xy_and_point_from_args(*args)

      ret = FFIProj4.pj_fwd(xy, self.ptr)
      result = FFIProj4.pj_get_errno_ref.read_int

      if result == 0
        point.x = ret[:x]
        point.y = ret[:y]
        point.z = 0 if point.respond_to?(:z=)
        point
      else
        raise Proj4::Error.instantiate_error(result)
      end
    end
    alias :forward_rad! :forward!
    alias :forwardRad! :forward!

    def forward(*args)
      self.forward!(*dup_args(*args))
    end
    alias :forward_rad :forward
    alias :forwardRad :forward

    def forward_deg!(*args)
      self.forward!(*args_deg_to_rad(*args))
    end
    alias :forwardDeg! :forward_deg!

    def forward_deg(*args)
      self.forward_deg!(*dup_args(*args))
    end
    alias :forwardDeg :forward_deg

    def forward_all!(collection)
      collection.each do |args|
        self.forward_all!(proj, *args)
      end
      collection
    end

    def forward_all(proj, collection)
      collection.collect do |args|
        self.forward!(proj, *(dup_args(*args)))
      end
    end

    def inverse!(*args)
      xy, point = xy_and_point_from_args(*args)

      ret = FFIProj4.pj_inv(xy, self.ptr)
      result = FFIProj4.pj_get_errno_ref.read_int

      if result == 0
        point.x = ret[:x]
        point.y = ret[:y]
        point.z = 0 if point.respond_to?(:z=)
        point
      else
        raise Proj4::Error.instantiate_error(result)
      end
    end
    alias :inverse_rad! :inverse!
    alias :inverseRad! :inverse!

    def inverse(*args)
      self.inverse!(*dup_args(*args))
    end
    alias :inverse_rad :inverse
    alias :inverseRad :inverse

    def inverse_deg!(*args)
      self.inverse!(*args).to_deg!
    end
    alias :inverseDeg! :inverse_deg!

    def inverse_deg(*args)
      self.inverse_deg!(*dup_args(*args))
    end
    alias :inverseDeg :inverse_deg

    def transform!(proj, *args)
      perform_transform(:pj_transform, proj, *args)
    end
    alias :transform_rad! :transform!
    alias :transformRad! :transform!

    def transform(proj, *args)
      self.transform!(proj, *(dup_args(*args)))
    end
    alias :transform_rad :transform
    alias :transformRad :transform

    def transform_deg!(proj, *args)
      self.transform!(proj, *args).to_deg!
    end

    def transform_deg(proj, *args)
      self.transform_deg!(proj, *(dup_args(*args)))
    end

    def datum_transform!(proj, *args)
      perform_transform(:pj_datum_transform, proj, *args)
    end
    alias :datum_transform_rad! :datum_transform!

    def datum_transform(proj, *args)
      self.datum_transform!(proj, *(dup_args(*args)))
    end

    def datum_transform_deg!(proj, *args)
      self.datum_transform!(proj, *args).to_deg!
    end

    def datum_transform_deg(proj, *args)
      self.datum_transform_deg!(proj, *(dup_args(*args)))
    end

    def transform_all!(proj, collection)
      collection.each do |args|
        self.transform!(proj, *args)
      end
      collection
    end

    def transform_all(proj, collection)
      collection.collect do |args|
        self.transform!(proj, *(dup_args(*args)))
      end
    end

    def projection
      self.to_hash[:proj]
    end

    def datum
      self.to_hash[:datum]
    end

    private
      def xy_and_point_from_args(*args)
        if args.length == 1
          point = args.first
          if point.is_a?(Proj4::ProjXY)
            [ point, Proj4::Point.new(point.x, point.y) ]
          elsif point.respond_to?(:x) && point.respond_to?(:y)
            [ Proj4::ProjXY.alloc_in.init(point.x, point.y), point ]
          else
            raise ArgumentError.new("Expected a Proj4::ProjXY, a Proj4::Point or an object that responds to x and y methods.")
          end
        elsif args.length == 2
          [ Proj4::ProjXY.alloc_in.init(args[0], args[1]), Proj4::Point.new(args[0], args[1]) ]
        else
          raise ArgumentError.new("Wrong number of arguments #{args.length} for 1-2")
        end
      end

      def point_from_args(*args)
        if args.length >= 2
          Proj4::Point.new(*args)
        elsif args.length == 1 && args.first.respond_to?(:x) && args.first.respond_to?(:y)
          args.first
        else
          raise ArgumentError.new("Expected either coordinates, a Proj4::Point or an object that responds to x and y methods.")
        end
      end

      def args_deg_to_rad(*args)
        args.collect { |value|
          deg_to_rad!(value)
        }
      end

      def args_rad_to_deg(*args)
        args.collect { |value|
          rad_to_deg!(value)
        }
      end

      def dup_args(*args)
        args.collect { |value|
          if !value.is_a?(Numeric) && value.respond_to?(:dup)
            value.dup
          else
            value
          end
        }
      end

      def perform_transform(transform_method, proj, *args)
        if !proj.is_a?(Proj4::Projection)
          raise TypeError.new("Expected a Proj4::Projection")
        end

        point = point_from_args(*args)

        x_ptr = FFI::MemoryPointer.new(:double)
        y_ptr = FFI::MemoryPointer.new(:double)
        z_ptr = FFI::MemoryPointer.new(:double)

        x_ptr.write_double(point.x)
        y_ptr.write_double(point.y)
        z_ptr.write_double(point.z.nil? ? 0 : point.z) if point.respond_to?(:z)

        result = FFIProj4.send(transform_method, self.ptr, proj.ptr, 1, 1, x_ptr, y_ptr, z_ptr)

        if result >= 0 && !bool_result(result)
          point.x = x_ptr.read_double
          point.y = y_ptr.read_double
          point.z = z_ptr.read_double if point.respond_to?(:z=)
          point
        else
          raise Proj4::Error.instantiate_error(result)
        end
      end
  end
end

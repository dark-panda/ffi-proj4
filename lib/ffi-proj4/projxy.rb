
module Proj4
  class ProjXY < FFI::Struct
    layout(
      :x, :double,
      :y, :double
    )

    def initialize(*args)
      case args.first
        when FFI::Pointer, FFI::Buffer
          super(*args)
        when FFI::Buffer
          super(*args)
        else
          if !args.empty?
            self[:x], self[:y] = args.map(&:to_f)
          end
      end
    end

    def x=(v)
      self[:x] = v
    end

    def y=(v)
      self[:y] = v
    end

    def x
      self[:x]
    end

    def y
      self[:y]
    end

    def to_deg!
      self[:x] = self[:x] * Proj4::RAD_TO_DEG
      self[:y] = self[:y] * Proj4::RAD_TO_DEG
      self
    end

    def to_deg
      self.dup.to_deg!
    end

    def to_rad!
      self[:x] = self[:x] * Proj4::DEG_TO_RAD
      self[:y] = self[:y] * Proj4::DEG_TO_RAD
      self
    end

    def to_rad
      self.dup.to_rad!
    end

    private
      def is_ffi?(arg)
        arg.is_a?(FFI::Pointer) || arg.is_a?(FFI::Buffer)
      end
  end
end

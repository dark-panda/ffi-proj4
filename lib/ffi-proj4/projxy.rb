
module Proj4
  class ProjXY < FFI::Struct
    layout(
      :x, :double,
      :y, :double
    )

    def initialize(*args)
      case args.first
        when FFI::Pointer, FFI::Buffer
          super
        else
          super()
          self.init(*args)
      end
    end

    def init(*args)
      if !args.empty?
        self[:x] = args[0].to_f
        self[:y] = args[1].to_f
      end

      self
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
  end
end

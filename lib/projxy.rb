
module Proj4
  class ProjXY < FFI::Struct
    layout(
      :x, :double,
      :y, :double
    )

    def initialize(*args)
      if args.first.is_a?(FFI::Pointer)
        super(*args)
      else
        self[:x] = args.first.to_f
        self[:y] = args[1].to_f
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
  end
end

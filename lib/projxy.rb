
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
        self[:x] = if args.first.respond_to?(:read_double)
          args.first.read_double
        else
          args.first.to_f
        end

        self[:y] = if args[1].respond_to?(:read_double)
          args.first.read_double
        else
          args[1].to_f
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
  end
end

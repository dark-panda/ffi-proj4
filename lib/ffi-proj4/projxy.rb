
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

    private
      def is_ffi?(arg)
        arg.is_a?(FFI::Pointer) || arg.is_a?(FFI::Buffer)
      end
  end
end

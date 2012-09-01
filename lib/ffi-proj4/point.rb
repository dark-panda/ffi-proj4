
module Proj4
  class Point
    attr_accessor :x, :y, :z

    def initialize(x, y, z = nil)
      @x, @y, @z = x, y, z
    end
  end
end

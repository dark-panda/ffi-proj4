
module Proj4
  class Point
    include Proj4::Tools

    attr_accessor :x, :y, :z

    def initialize(x, y, z = nil)
      @x, @y, @z = x, y, z
    end

    alias :lon :x
    alias :lon= :x=
    alias :lat :y
    alias :lat= :y=

    def to_deg!
      self.x = rad_to_deg(self.x)
      self.y = rad_to_deg(self.y)
      self
    end

    def to_deg
      self.dup.to_deg!
    end

    def to_rad!
      self.x = deg_to_rad(self.x)
      self.y = deg_to_rad(self.y)
      self
    end

    def to_rad
      self.dup.to_rad!
    end
  end
end

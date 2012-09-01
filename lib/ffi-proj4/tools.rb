
module Proj4
  module Tools
    def bool_result(r)
      case r
        when 1
          true
        when 0
          false
        else
          raise RuntimeError.new("Unexpected boolean result: #{r}")
      end
    end

    def rad_to_deg!(rad)
      unless rad.nil?
        case rad
          when Proj4::Point, Proj4::ProjXY
            rad.to_deg!
          else
            rad * Proj4::RAD_TO_DEG
        end
      end
    end

    def rad_to_deg(rad)
      rad_to_deg!(
        !rad.is_a?(Numeric) && rad.respond_to?(:dup) ?
          rad.dup :
          rad
      )
    end

    def deg_to_rad!(deg)
      unless deg.nil?
        case deg
          when Proj4::Point, Proj4::ProjXY
            deg.to_rad!
          else
            deg * Proj4::DEG_TO_RAD
        end
      end
    end

    def deg_to_rad(deg)
      deg_to_rad!(
        !deg.is_a?(Numeric) && deg.respond_to?(:dup) ?
          deg.dup :
          deg
      )
    end

    class << self
      include Proj4::Tools
    end
  end
end

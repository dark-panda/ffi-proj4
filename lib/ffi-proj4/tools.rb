
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

    def rad_to_deg(rad)
      rad * Proj4::RAD_TO_DEG
    end

    def deg_to_rad(deg)
      deg * Proj4::DEG_TO_RAD
    end

    class << self
      include Proj4::Tools
    end
  end
end

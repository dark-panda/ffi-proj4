
$: << File.dirname(__FILE__)
require 'test_helper'

class SimpleTransformationTests < Test::Unit::TestCase
  include TestHelper

  def setup
    @proj_gk = Proj4::Projection.new(["init=epsg:31467"])
    @lon =  8.4302123334
    @lat = 48.9906726079
    @rw = 3458305
    @hw = 5428192
  end

  def test_forward_gk
    result = @proj_gk.forward_deg(@lon, @lat)
    assert_in_delta(@rw, result.x, 0.1)
    assert_in_delta(@hw, result.y, 0.1)
  end

  def test_inverse_gk
    result = @proj_gk.inverse(@rw, @hw)
    assert_in_delta(@lon, Proj4::Tools.rad_to_deg(result.x), TOLERANCE)
    assert_in_delta(@lat, Proj4::Tools.rad_to_deg(result.y), TOLERANCE)
  end

  def test_out_of_bounds
    assert_raise Proj4::LatitudeOrLongitudeExceededLimitsError do
      @proj_gk.forward_deg(190, 92)
    end
  end
end

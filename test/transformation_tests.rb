
$: << File.dirname(__FILE__)
require 'test_helper'

class TransformationTests < Test::Unit::TestCase
  include TestHelper

  def setup
    @proj_wgs84 = Proj4::Projection.new(["init=epsg:4326"])
    @proj_gk    = Proj4::Projection.new(["init=epsg:31467"])
    @proj_merc  = Proj4::Projection.new(["proj=merc"])
    @lon =  8.4293092923
    @lat = 48.9896114523
    @rw = 3458305
    @hw = 5428192
    @zw = -5.1790915237
  end

  def test_gk_to_wgs84
    to = @proj_gk.transform(@proj_wgs84, @rw, @hw, @zw)

    assert_in_delta @lon, to.x * Proj4::RAD_TO_DEG, TOLERANCE
    assert_in_delta @lat, to.y * Proj4::RAD_TO_DEG, TOLERANCE
    assert_in_delta 0, to.z, TOLERANCE
  end

  def test_wgs84_to_gk
    point = @proj_wgs84.transform(
      @proj_gk,
      @lon * Proj4::DEG_TO_RAD,
      @lat * Proj4::DEG_TO_RAD,
      0
    )
    assert_equal @rw, point.x.round
    assert_equal @hw, point.y.round
    assert_in_delta @zw, point.z, TOLERANCE
  end

  def test_no_dst_proj
    assert_raise ArgumentError do
      @proj_wgs84.transform(
        nil,
        @lon * Proj4::DEG_TO_RAD,
        @lat * Proj4::DEG_TO_RAD,
        0
      )
    end
  end

  def test_mercator_at_pole_raise
    assert_raise Proj4::TransformError do
      @proj_wgs84.transform(
        @proj_merc,
        0,
        90 * Proj4::DEG_TO_RAD,
        0
      )
    end
  end
end

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
    result = @proj_gk.forward_rad(@lon, @lat)
    assert_in_delta @rw, result.x, 0.1
    assert_in_delta @hw, result.y, 0.1
  end

  def test_inverse_gk
    result = @proj_gk.inverse(@rw, @hw)
    assert_in_delta @lon, Proj4::Tools.rad_to_deg(result.x), TOLERANCE
    assert_in_delta @lat, Proj4::Tools.rad_to_deg(result.y), TOLERANCE
  end

  def test_out_of_bounds
    assert_raise Proj4::TransformError do
      @proj_gk.forward_deg(190, 92)
    end
  end
end

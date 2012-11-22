
$: << File.dirname(__FILE__)
require 'test_helper'

class SimpleTransformationTests < MiniTest::Unit::TestCase
  include TestHelper

  LONG = 8.4302123334
  LAT = 48.9906726079
  RW = 3458305
  HW = 5428192

  def simple_transformation_tester(method, expected_x, expected_y, proj, x, y, tolerance = TOLERANCE)
    point = Proj4::Point.new(x, y)
    result = proj.send("#{method}!", point)

    assert_equal(result.object_id, point.object_id)
    assert_in_delta(expected_x, result.x, tolerance)
    assert_in_delta(expected_y, result.y, tolerance)

    point = Proj4::Point.new(x, y)
    result = proj.send(method, point)

    refute_equal(result.object_id, point.object_id)
    assert_in_delta(x, point.x, tolerance)
    assert_in_delta(y, point.y, tolerance)
    assert_in_delta(expected_x, result.x, tolerance)
    assert_in_delta(expected_y, result.y, tolerance)
  end

  def test_forward
    simple_transformation_tester(
      :forward,
      RW,
      HW,
      PROJ_GK,
      Proj4::Tools.deg_to_rad(LONG),
      Proj4::Tools.deg_to_rad(LAT),
      0.1
    )
  end

  def test_inverse
    simple_transformation_tester(
      :inverse,
      Proj4::Tools.deg_to_rad(LONG),
      Proj4::Tools.deg_to_rad(LAT),
      PROJ_GK,
      RW,
      HW
    )
  end

  def test_forward_deg
    simple_transformation_tester(
      :forward_deg,
      RW,
      HW,
      PROJ_GK,
      LONG,
      LAT,
      0.1
    )
  end

  def test_inverse_deg
    simple_transformation_tester(
      :inverse_deg,
      LONG,
      LAT,
      PROJ_GK,
      RW,
      HW
    )
  end

  def test_out_of_bounds
    assert_raises Proj4::LatitudeOrLongitudeExceededLimitsError do
      PROJ_GK.forward_deg(190, 92)
    end
  end
end

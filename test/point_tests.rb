
$: << File.dirname(__FILE__)
require 'test_helper'

class PointTests < Test::Unit::TestCase
  include TestHelper

  def rad_deg_tester(method, expected_x, expected_y, expected_z, x, y, z)
    point = Proj4::Point.new(x, y, z)
    point.send("#{method}!")

    assert_in_delta(expected_x, point.x, TOLERANCE)
    assert_in_delta(expected_y, point.y, TOLERANCE)
    assert_in_delta(expected_z, point.z, TOLERANCE)

    point = Proj4::Point.new(x, y, z)
    point2 = point.send(method)

    assert_in_delta(x, point.x, TOLERANCE)
    assert_in_delta(y, point.y, TOLERANCE)
    assert_in_delta(z, point.z, TOLERANCE)

    assert_in_delta(expected_x, point2.x, TOLERANCE)
    assert_in_delta(expected_y, point2.y, TOLERANCE)
    assert_in_delta(expected_z, point2.z, TOLERANCE)
  end

  def test_to_rad
    rad_deg_tester(:to_rad,
      1.0471975511965976,
      1.5707963267948966,
      0.7853981633974483,
      60,
      90,
      45
    )
  end

  def test_to_deg
    rad_deg_tester(:to_deg,
      60,
      90,
      45,
      1.0471975511965976,
      1.5707963267948966,
      0.7853981633974483
    )
  end
end

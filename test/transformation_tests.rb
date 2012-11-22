
$: << File.dirname(__FILE__)
require 'test_helper'

class TransformationTests < MiniTest::Unit::TestCase
  include TestHelper

  def setup
    @proj_wgs84 = Proj4::Projection.new(["init=epsg:4326"])
    @proj_gk = Proj4::Projection.new(["init=epsg:31467"])
    @proj_merc  = Proj4::Projection.new(["proj=merc"])
    @lon = 8.429263044355672
    @lat = 48.98963932449638
    @z = 46.318651656620204
    @rw = 3458305
    @hw = 5428192
    @zw = -51.49743285309523
  end

  def test_gk_to_wgs84
    from = Proj4::Point.new(@rw, @hw, @zw)
    to = @proj_gk.transform(@proj_wgs84, from)
    refute_equal(from.object_id, to.object_id)
    assert_in_delta(@lon, to.x * Proj4::RAD_TO_DEG, TOLERANCE)
    assert_in_delta(@lat, to.y * Proj4::RAD_TO_DEG, TOLERANCE)
    assert_in_delta(0, to.z, TOLERANCE * (10 ** 3))
  end

  def test_gk_to_wgs84_inplace
    from = Proj4::Point.new(@rw, @hw, @zw)
    to = @proj_gk.transform!(@proj_wgs84, from)
    assert_equal(from.object_id, to.object_id)
    assert_in_delta(@lon, to.x * Proj4::RAD_TO_DEG, TOLERANCE)
    assert_in_delta(@lat, to.y * Proj4::RAD_TO_DEG, TOLERANCE)
    assert_in_delta(0, to.z, TOLERANCE * (10 ** 3))
  end

  def test_wgs84_to_gk
    point = @proj_wgs84.transform(@proj_gk, Proj4::Point.new(@lon * Proj4::DEG_TO_RAD, @lat * Proj4::DEG_TO_RAD, 0))
    assert_equal(@rw, point.x.round)
    assert_equal(@hw, point.y.round)
    assert_in_delta(@zw, point.z, TOLERANCE)
  end

  def test_no_dst_proj
    assert_raises TypeError do
      point = @proj_wgs84.transform(nil, Proj4::Point.new(@lon * Proj4::DEG_TO_RAD, @lat * Proj4::DEG_TO_RAD, 0))
    end
  end

  def test_not_a_point
    assert_raises TypeError do
      point = @proj_wgs84.transform(@proj_gk, nil)
    end
  end

  def test_mercator_at_pole_raise
    assert_raises Proj4::ToleranceConditionError do
      point = @proj_wgs84.transform(@proj_merc, Proj4::Point.new(0, 90 * Proj4::DEG_TO_RAD, 0))
    end
  end

  def test_mercator_at_pole_rescue
    begin
      point = @proj_wgs84.transform(@proj_merc, Proj4::Point.new(0, 90 * Proj4::DEG_TO_RAD, 0))
    rescue => exception
      assert_kind_of(Proj4::ToleranceConditionError, exception)
      assert_equal('tolerance condition error', exception.message)
      assert_equal(20, exception.errnum)
    end
  end

  class XYPoint
    attr_accessor :x, :y, :extra

    def initialize(x, y, extra)
      @x = x
      @y = y
      @extra = extra
    end
  end

  def test_no_z
    point = @proj_gk.transform(@proj_wgs84, XYPoint.new(@rw, @hw, 'foo'))
    assert_kind_of(XYPoint, point)
    assert_equal('foo', point.extra)
    assert_in_delta(@lon, point.x * Proj4::RAD_TO_DEG, TOLERANCE)
    assert_in_delta(@lat, point.y * Proj4::RAD_TO_DEG, TOLERANCE)
  end

  def test_no_float
    assert_raises TypeError do
      @proj_gk.transform(@proj_wgs84, XYPoint.new('x', 'y', 'foo'))
    end
  end

  def test_collection
    from0 = Proj4::Point.new(@rw, @hw, @zw)
    from1 = Proj4::Point.new(0, 0, 0)
    collection = @proj_gk.transform_all!(@proj_wgs84, [ from0, from1 ])
    to0 = collection[0]
    to1 = collection[1]
    assert_equal(from1.object_id, to1.object_id)
    assert_in_delta(@lon, to0.x * Proj4::RAD_TO_DEG, TOLERANCE)
    assert_in_delta(@lat, to0.y * Proj4::RAD_TO_DEG, TOLERANCE)
    assert_in_delta(0, to0.z, TOLERANCE * (10 ** 3))
  end
end

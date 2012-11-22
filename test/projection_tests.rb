
$: << File.dirname(__FILE__)
require 'test_helper'

class ProjectionTests < MiniTest::Unit::TestCase
  include TestHelper

  def definition_sorter(definition)
    definition.split(/\s+/).sort.join(' ')
  end

  def definition_tester(expected, proj)
    assert_equal(
      definition_sorter(expected),
      definition_sorter(Proj4::Projection.new(proj).definition)
    )
  end

  def hash_tester(expected, proj)
    hash = proj.to_hash
    assert_equal(expected.size, hash.size)

    expected.each do |k, v|
      assert_equal(v, hash[k], " Expected #{v} for #{k}, got #{hash[k]}")
    end
  end

  def test_read_strings
    definition_tester(
      '+init=epsg:4326 +proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs +towgs84=0,0,0',
      'init=epsg:4326'
    )

    definition_tester(
      '+datum=potsdam +ellps=bessel +init=epsg:31467 +k=1 +lat_0=0 +lon_0=9 +no_defs +proj=tmerc +towgs84=598.1,73.7,418.2,0.202,0.045,-2.455,6.7 +units=m +x_0=3500000 +y_0=0',
      'init=epsg:31467'
    )

    definition_tester(
      '+init=epsg:31528 +proj=utm +zone=28 +a=6378249.2 +b=6356515 +towgs84=-23,259,-9,0,0,0,0 +units=m +no_defs',
      'init=epsg:31528'
    )

    definition_tester(
      '+proj=ortel +lon_0=90w +ellps=WGS84',
      'proj=ortel lon_0=90w'
    )

    assert_raises(Proj4::ProjectionParseError) do
      definition_tester(
        '',
        'gibberish'
      )
    end
  end

  def test_read_arrays
    definition_tester(
      '+init=epsg:4326 +proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs +towgs84=0,0,0',
      [ 'init=epsg:4326' ]
    )

    definition_tester(
      '+datum=potsdam +ellps=bessel +init=epsg:31467 +k=1 +lat_0=0 +lon_0=9 +no_defs +proj=tmerc +towgs84=598.1,73.7,418.2,0.202,0.045,-2.455,6.7 +units=m +x_0=3500000 +y_0=0',
      [ 'init=epsg:31467' ]
    )

    definition_tester(
      '+init=epsg:31528 +proj=utm +zone=28 +a=6378249.2 +b=6356515 +towgs84=-23,259,-9,0,0,0,0 +units=m +no_defs',
      [ 'init=epsg:31528' ]
    )

    definition_tester(
      '+proj=ortel +lon_0=90w +ellps=WGS84',
      [ 'proj=ortel', 'lon_0=90w' ]
    )

    assert_raises(Proj4::ProjectionParseError) do
      definition_tester(
        '',
        [ 'gibberish' ]
      )
    end
  end

  def test_read_hashes
    definition_tester(
      '+init=epsg:4326 +proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs +towgs84=0,0,0',
      { :init => 'epsg:4326' }
    )

    definition_tester(
      '+datum=potsdam +ellps=bessel +init=epsg:31467 +k=1 +lat_0=0 +lon_0=9 +no_defs +proj=tmerc +towgs84=598.1,73.7,418.2,0.202,0.045,-2.455,6.7 +units=m +x_0=3500000 +y_0=0',
      { :init => 'epsg:31467' }
    )

    definition_tester(
      '+init=epsg:31528 +proj=utm +zone=28 +a=6378249.2 +b=6356515 +towgs84=-23,259,-9,0,0,0,0 +units=m +no_defs',
      { :init => 'epsg:31528' }
    )

    definition_tester(
      '+lon_0=90w +proj=ortel +ellps=WGS84',
      { :proj => 'ortel', :lon_0 => '90w' }
    )

    assert_raises(Proj4::ProjectionParseError) do
      definition_tester(
        '',
        { :proj => 'gibberish' }
      )
    end
  end

  def test_has_inverse
    # XXX - checking if a projection has an inverse isn't supported by the
    # PROJ.4 public API.
    # assert(PROJ_WGS84.hasInverse?)
    # assert(PROJ_GK.hasInverse?)
    # assert(PROJ_CONAKRY.hasInverse?)
    # assert(!PROJ_ORTEL.hasInverse?)
  end

  def test_is_latlong
    %w{ isLatLong? lat_long? }.each do |method|
      assert(PROJ_WGS84.send(method))
      assert(!PROJ_GK.send(method))
      assert(!PROJ_CONAKRY.send(method))
      assert(!PROJ_ORTEL.send(method))
    end
  end

  def test_is_geocent
    %w{ isGeocent? isGeocentric? geocentric? }.each do |method|
      assert(!PROJ_WGS84.send(method))
      assert(!PROJ_GK.send(method))
      assert(!PROJ_CONAKRY.send(method))
      assert(!PROJ_ORTEL.send(method))
    end
  end

  def test_get_def
    %w{ getDef definition }.each do |method|
      assert_equal(
        '+init=epsg:4326 +proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0',
        PROJ_WGS84.send(method).strip
      )

      assert_equal(
        '+init=epsg:31467 +proj=tmerc +lat_0=0 +lon_0=9 +k=1 +x_0=3500000 +y_0=0 +datum=potsdam +units=m +no_defs +ellps=bessel +towgs84=598.1,73.7,418.2,0.202,0.045,-2.455,6.7',
        PROJ_GK.send(method).strip
      )

      assert_equal(
        '+init=epsg:31528 +proj=utm +zone=28 +a=6378249.2 +b=6356515 +towgs84=-23,259,-9,0,0,0,0 +units=m +no_defs',
        PROJ_CONAKRY.send(method).strip
      )

      assert_equal(
        '+proj=ortel +lon_0=90w +ellps=WGS84',
        PROJ_ORTEL.send(method).strip
      )
    end
  end

  def test_inspect
    assert_equal('#<Proj4::Projection +init=epsg:4326 +proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0>', PROJ_WGS84.to_s)
    assert_equal('#<Proj4::Projection +init=epsg:4326 +proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0>', PROJ_WGS84.inspect)
  end

  def test_to_hash
    hash_tester(PROJ_WGS84_HASH, PROJ_WGS84)
    hash_tester(PROJ_GK_HASH, PROJ_GK)
    hash_tester(PROJ_CONAKRY_HASH, PROJ_CONAKRY)
    hash_tester(PROJ_ORTEL_HASH, PROJ_ORTEL)
  end

  def test_projection
    assert_equal('longlat', PROJ_WGS84.projection)
    assert_equal('tmerc', PROJ_GK.projection)
    assert_equal('utm', PROJ_CONAKRY.projection)
    assert_equal('ortel', PROJ_ORTEL.projection)
  end

  def test_datum
    assert_equal('WGS84', PROJ_WGS84.datum)
    assert_equal('potsdam', PROJ_GK.datum)
    assert_nil(PROJ_CONAKRY.datum)
    assert_nil(PROJ_ORTEL.datum)
  end

  def test_shortcut_create
    proj = Proj4::Projection.new("epsg:4326")

    hash_tester(PROJ_WGS84_HASH, proj)
  end
end

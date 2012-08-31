
$: << File.dirname(__FILE__)
require 'test_helper'

class ProjectionTests < Test::Unit::TestCase
  include TestHelper

  def definition_sorter(definition)
    definition.split(/\s+/).sort.join(' ')
  end

  def test_read_strings
    tester = lambda { |expected, proj|
      assert_equal(
        definition_sorter(expected),
        definition_sorter(Proj4::Projection.new(proj).definition)
      )
    }

    tester[
      '+init=epsg:4326 +proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs +towgs84=0,0,0',
      'init=epsg:4326'
    ]

    tester[
      '+datum=potsdam +ellps=bessel +init=epsg:31467 +k=1 +lat_0=0 +lon_0=9 +no_defs +proj=tmerc +towgs84=598.1,73.7,418.2,0.202,0.045,-2.455,6.7 +units=m +x_0=3500000 +y_0=0',
      'init=epsg:31467'
    ]

    tester[
      '+init=epsg:31528 +proj=utm +zone=28 +a=6378249.2 +b=6356515 +towgs84=-23,259,-9,0,0,0,0 +units=m +no_defs',
      'init=epsg:31528'
    ]

    tester[
      '+proj=ortel +lon_0=90w +ellps=WGS84',
      'proj=ortel lon_0=90w'
    ]

    assert_raise(Proj4::ProjectionParseError) do
      tester[
        '',
        'gibberish'
      ]
    end
  end

  def test_read_arrays
    tester = lambda { |expected, proj|
      assert_equal(
        definition_sorter(expected),
        definition_sorter(Proj4::Projection.new(proj).definition)
      )
    }

    tester[
      '+init=epsg:4326 +proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs +towgs84=0,0,0',
      [ 'init=epsg:4326' ]
    ]

    tester[
      '+datum=potsdam +ellps=bessel +init=epsg:31467 +k=1 +lat_0=0 +lon_0=9 +no_defs +proj=tmerc +towgs84=598.1,73.7,418.2,0.202,0.045,-2.455,6.7 +units=m +x_0=3500000 +y_0=0',
      [ 'init=epsg:31467' ]
    ]

    tester[
      '+init=epsg:31528 +proj=utm +zone=28 +a=6378249.2 +b=6356515 +towgs84=-23,259,-9,0,0,0,0 +units=m +no_defs',
      [ 'init=epsg:31528' ]
    ]

    tester[
      '+proj=ortel +lon_0=90w +ellps=WGS84',
      [ 'proj=ortel', 'lon_0=90w' ]
    ]

    assert_raise(Proj4::ProjectionParseError) do
      tester[
        '',
        [ 'gibberish' ]
      ]
    end
  end

  def test_read_hashes
    tester = lambda { |expected, proj|
      assert_equal(
        definition_sorter(expected),
        definition_sorter(Proj4::Projection.new(proj).definition)
      )
    }

    tester[
      '+init=epsg:4326 +proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs +towgs84=0,0,0',
      { :init => 'epsg:4326' }
    ]

    tester[
      '+datum=potsdam +ellps=bessel +init=epsg:31467 +k=1 +lat_0=0 +lon_0=9 +no_defs +proj=tmerc +towgs84=598.1,73.7,418.2,0.202,0.045,-2.455,6.7 +units=m +x_0=3500000 +y_0=0',
      { :init => 'epsg:31467' }
    ]

    tester[
      '+init=epsg:31528 +proj=utm +zone=28 +a=6378249.2 +b=6356515 +towgs84=-23,259,-9,0,0,0,0 +units=m +no_defs',
      { :init => 'epsg:31528' }
    ]

    tester[
      '+lon_0=90w +proj=ortel +ellps=WGS84',
      { :proj => 'ortel', :lon_0 => '90w' }
    ]

    assert_raise(Proj4::ProjectionParseError) do
      tester[
        '',
        { :proj => 'gibberish' }
      ]
    end
  end
end

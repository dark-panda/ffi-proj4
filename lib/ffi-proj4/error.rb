
module Proj4
  class Error < StandardError
    ERRORS = %w{
      Unknown
      NoArgsInInitList
      NoOptionsInInitFile
      NoColonInInitString
      ProjectionNotNamed
      UnknownProjectionId
      EffectiveEccentricityEq1
      UnknownUnitConversionId
      InvalidBooleanParamArgument
      UnknownEllipticalParameterName
      ReciprocalFlatteningIsZero
      RadiusReferenceLatitudeGt90
      SquaredEccentricityLessThanZero
      MajorAxisOrRadiusIsZeroOrNotGiven
      LatitudeOrLongitudeExceededLimits
      InvalidXOrY
      ImproperlyFormedDMSValue
      NonConvergentInverseMeridinalDist
      NonConvergentInversePhi2
      AcosOrAsinArgTooBig
      ToleranceCondition
      ConicLat1EqMinusLat2
      Lat1GreaterThan90
      Lat1IsZero
      LatTsGreater90
      NoDistanceBetweenControlPoints
      ProjectionNotSelectedToBeRotated
      WSmallerZeroOrMSmallerZero
      LsatNotInRange
      PathNotInRange
      HSmallerZero
      KSmallerZero
      Lat0IsZeroOr90OrAlphaIsZero
      Lat1EqLat2OrLat1IsZeroOrLat2Is90
      EllipticalUsageRequired
      InvalidUTMZoneNumber
      ArgsOutOfRangeForTchebyEval
      NoProjectionToBeRotated
      FailedToLoadNAD2783CorrectionFile
      BothNAndMMustBeSpecdAndGreaterZero
      NSmallerZeroOrNGreaterOneOrNotSpecified
      Lat1OrLat2NotSpecified
      AbsoluteLat1EqLat2
      Lat0IsHalfPiFromMeanLat
      UnparseableCoordinateSystemDefinition
      GeocentricTransformationMissingZOrEllps
      UnknownPrimeMeridianConversionId
      IllegalAxisOrientationCombination
      PointNotWithinAvailableDatumShiftGrids
      InvalidSweepAxis
    }

    def self.list
       ERRORS
    end

    def self.error(errno)
      ERRORS[errno.abs] || 'Unknown'
    end

    def self.raise_error(errno)
      raise self.instantiate_error(errno), caller[0..-1]
    end

    def self.instantiate_error(errno)
      name = self.error(errno)
      Proj4.const_get("#{name}Error").new(Proj4::FFIProj4.pj_strerrno(errno))
    end

    def errno
      self.class.errno
    end
    alias :errnum :errno
  end

  Error::ERRORS.each_with_index do |err, index|
    Proj4.module_eval(<<-EOF, __FILE__, __LINE__ + 1)
      class #{err}Error < Proj4::Error
        class << self
          def errno
            #{index}
          end
          alias :errnum :errno
        end
      end
    EOF
  end
end

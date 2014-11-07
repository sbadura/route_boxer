module RouteBoxer
  class LatLng
    include RouteBoxer
    attr_accessor :lat, :lng

    alias_method :latitude, :lat
    alias_method :latitude=, :lat=

    alias_method :longitude, :lng
    alias_method :longitude=, :lng=

    def initialize(lat = nil, lng = nil)
      lat = lat.to_f if lat && !lat.is_a?(Numeric)
      lng = lng.to_f if lng && !lng.is_a?(Numeric)
      @lat = lat
      @lng = lng
    end

    def lat=(lat)
      @lat = lat.to_f if lat
    end

    def lng=(lng)
      @lng = lng.to_f if lng
    end

    def ll
      "#{lat},#{lng}"
    end

    def to_a
      [lat, lng]
    end

    def equals(other)
      lat == other.lat && lng == other.lng
    end

    def rhumb_destination_point(brng, dist, r = 6378137)
      d = dist / r.to_f

      brng = deg2rad(brng)
      lat1 = deg2rad(lat)
      lng1 = deg2rad(lng)

      dLat = d * Math.cos(brng)
      dLat = 0 if dLat.abs < 1e-10

      lat2 = lat1 + dLat
      dPhi = Math.log(Math.tan(lat2 / 2.0 + Math::PI / 4.0) / Math.tan(lat1 / 2.0 + Math::PI / 4.0))
      q = (dPhi != 0) ? dLat / dPhi.to_f : Math.cos(lat1)
      dLon = d * Math.sin(brng) / q

      if lat2.abs > (Math::PI / 2.0)
        lat2 = lat2 > 0 ? Math::PI - lat2 : -Math::PI - lat2
      end

      lng2 = (lng1 + dLon + 3 * Math::PI) % (2 * Math::PI) - Math::PI
      lat2 = rad2deg(lat2)
      lng2 = rad2deg(lng2)

      LatLng.new(lat2, lng2)
    end

    def rhumb_bearing_to(dest)
      dLon = deg2rad(dest.lng - lng)
      dPhi = Math.log(Math.tan(deg2rad(dest.lat) / 2 + Math::PI / 4) / Math.tan(deg2rad(lat) / 2 + Math::PI / 4))

      if dLon.abs > Math::PI
        dLon = dLon > 0 ? - (2 * Math::PI - dLon) : (2 * Math::PI + dLon)
      end

      to_brng(Math.atan2(dLon, dPhi))
    end

    def to_brng(number)
      (rad2deg(number) + 360) % 360
    end

  end
end

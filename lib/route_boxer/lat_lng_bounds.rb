module RouteBoxer
  class LatLngBounds
    attr_accessor :south_west, :north_east

    def initialize(south_west = nil, north_east = nil)
      @south_west = south_west
      @north_east = north_east
    end

    def contains(point)
      if @south_west.lat > point.lat || point.lat > @north_east.lat
        return false
      end

      return contains_lng(point.lng)
    end

    def contains_lng(lng)
      if crosses_antimeridian
        return lng <= @north_east.lng || lng >= @south_west.lng
      else
        return @south_west.lng <= lng && lng <= @north_east.lng
      end
    end

    def equals(other)
      south_west.equals(other.south_west) && north_east.equals(other.north_east)
    end

    def extend(point)
      if @north_east != nil
        new_south = [@south_west.lat, point.lat].min
        new_north = [@north_east.lat, point.lat].max
        new_west = @south_west.lng
        new_east = @north_east.lng

        if ! contains_lng(point.lng)
          extend_east_lng_span = lng_span(new_west, point.lng)
          extend_west_lng_span = lng_span(point.lng, new_east)

          if extend_east_lng_span <= extend_west_lng_span
            new_east = point.lng
          else
            new_west = point.lng
          end
        end

        @south_west = RouteBoxer::LatLng.new(new_south, new_west)
        @north_east = RouteBoxer::LatLng.new(new_north, new_east)
      else
        @south_west = @north_east = point
      end

      self
    end

    def lng_span(west, east)
      (west > east) ? (east + 360 - west) : (east - west)
    end

    def get_center
      if crosses_antimeridian
        span = lng_span(@south_west.lng, @north_east.lng)
        lng = normalize_lng(@south_west.lng + span / 2)
      else
        lng = (@south_west.lng + @north_east.lng) / 2
      end

      RouteBoxer::LatLng.new((@south_west.lat + @north_east.lat) / 2, lng)
    end

    def crosses_antimeridian
      @south_west.lng > @north_east.lng
    end

    def get_north_east
      @north_east
    end

    def get_south_west
      @south_west
    end

    def union(bounds)
      extend_by_lat_lng(bounds.get_south_west)
      extend_by_lat_lng(bounds.get_north_east)
      self
    end

    def to_span
      RouteBoxer::LatLng.new(@north_east.lat - @south_west.lat, lng_span(@south_west.lng, @north_east.lng))
    end

    def normalize_lng(lng)
      mod = lng % 360

      if mod == 180
        return 180
      end

      return mod < -180 ? mod + 360 : (mod > 180 ? mod - 360 : mod)
    end

  end
end

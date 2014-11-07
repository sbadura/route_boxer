module RouteBoxer
  class LatLngCollection
    attr_accessor :points

    def initialize(points)
      @points = points
    end

    def to_a
      collection = []

      @points.each do |point|
        unless point.is_a?(RouteBoxer::LatLng)
          point = RouteBoxer::LatLng.new(point[0], point[1])
        end

        collection << point
      end

      collection
    end

  end
end

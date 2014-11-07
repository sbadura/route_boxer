require "route_boxer/version"

require "route_boxer/lat_lng"
require "route_boxer/lat_lng_collection"
require "route_boxer/lat_lng_bounds"
require "route_boxer/core"

module RouteBoxer
  def deg2rad(deg)
    deg * Math::PI / 180
  end

  def rad2deg(rad)
    rad * 180 / Math::PI
  end
end

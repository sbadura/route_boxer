# RouteBoxer

Ruby implementation of Google RouteBoxer

http://google-maps-utility-library-v3.googlecode.com/svn/trunk/routeboxer/src/RouteBoxer.js


## Installation

Add this line to your application's Gemfile:

    gem 'route_boxer'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install route_boxer

## Usage

1. Get route with Google Directions API:

   results = JSON.parse(open("http://maps.googleapis.com/maps/api/directions/json?alternative=true&destination=Warsaw&language=en&mode=driving&origin=Cracow&sensor=false").read)

2. Decode response to LatLng points with 'polylines' gem:

   points = Polylines::Decoder.decode_polyline(result["routes"][0]["overview_polyline"]["points"])

3. Parse points to RouteBoxer::LatLng objects:

   points = points.map { |p| RouteBoxer::LatLng.new(p[0], p[1])}

4. Use RouteBoxer to get 'boxed' route:

   RouteBoxer::Core.new.box(points, 10)


## Contributing

1. Fork it ( http://github.com/<my-github-username>/route_boxer/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

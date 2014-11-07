module RouteBoxer
  class Core
    include RouteBoxer
    R = 6371

    attr_accessor :grid, :lat_grid, :lng_grid, :boxes_x, :boxes_y

    def initialize
      @lat_grid = []
      @lng_grid = []
      @boxes_x = []
      @boxes_y = []
    end

    def box(collection, range)
      vertices = collection.to_a
      @grid = build_grid(vertices, range)

      find_intersecting_cells(vertices)
      merge_intersecting_cells

      return (@boxes_x.length <= @boxes_y.length ? @boxes_x : @boxes_y)
    end

  private

    def build_grid(vertices, range)
      route_bounds = RouteBoxer::LatLngBounds.new
      vertices.each do |v|
        route_bounds.extend(v)
      end

      route_bounds_center = route_bounds.get_center
      @lat_grid << route_bounds_center.lat
      @lat_grid << route_bounds_center.rhumb_destination_point(0, range, R).lat

      i = 2
      while @lat_grid[i - 2] < route_bounds.get_north_east.lat
        @lat_grid << route_bounds_center.rhumb_destination_point(0, range * i, R).lat
        i += 1
      end

      i = 1
      while @lat_grid[1] > route_bounds.get_south_west.lat
        @lat_grid.unshift(route_bounds_center.rhumb_destination_point(180, range * i, R).lat)
        i += 1
      end

      @lng_grid << route_bounds_center.lng
      @lng_grid << route_bounds_center.rhumb_destination_point(90, range, R).lng

      i = 2
      while @lng_grid[i - 2] < route_bounds.get_north_east.lng
        @lng_grid << route_bounds_center.rhumb_destination_point(90, range * i, R).lng
        i += 1
      end

      i = 1
      while @lng_grid[1] > route_bounds.get_south_west.lng
        @lng_grid.unshift(route_bounds_center.rhumb_destination_point(270, range * i, R).lng)
        i += 1
      end

      lng_grid_length = @lng_grid.length
      lat_grid_length = @lat_grid.length

      grid = create_empty_array(lng_grid_length)

      i = 0
      while i < grid.length
        grid[i] = create_empty_array(lat_grid_length)
        i += 1
      end

      grid
    end

    def create_empty_array(length)
      [nil] * length
    end

    def find_intersecting_cells(vertices)
      hint_xy = get_cell_coords(vertices[0])
      mark_cell(hint_xy)

      i = 1
      while i < vertices.length
        grid_xy = get_grid_coords_from_hint(vertices[i], vertices[i - 1], hint_xy)

        if grid_xy[0] == hint_xy[0] && grid_xy[1] == hint_xy[1]
          i += 1
          next
        elsif (((hint_xy[0] - grid_xy[0]).abs == 1 && hint_xy[1] == grid_xy[1]) || (hint_xy[0] == grid_xy[0] && (hint_xy[1] - grid_xy[1]).abs == 1))
          mark_cell(grid_xy)
        else
          get_grid_intersects(vertices[i - 1], vertices[i], hint_xy, grid_xy)
        end

        hint_xy = grid_xy
        i += 1
      end
    end

    def get_cell_coords(latlng)
      x = 0
      while @lng_grid[x] < latlng.lng
        x += 1
      end

      y = 0
      while @lat_grid[y] < latlng.lat
        y += 1
      end

      [x - 1, y - 1]
    end

    def get_grid_coords_from_hint(latlng, hint_latlng, hint)
      x = nil
      y = nil

      if latlng.lng > hint_latlng.lng
        x = hint[0]
        while @lng_grid[x + 1] < latlng.lng
          x += 1
        end
      else
        x = hint[0]
        while @lng_grid[x] > latlng.lng
          x -= 1
        end
      end

      if latlng.lat > hint_latlng.lat
        y = hint[1]
        while @lat_grid[y + 1] < latlng.lat
          y += 1
        end
      else
        y = hint[1]
        while @lat_grid[y] > latlng.lat
          y -= 1
        end
      end

      [x, y]
    end

    def get_grid_intersects(start, stop, start_xy, stop_xy)
      brng = start.rhumb_bearing_to(stop)
      hint = start
      hint_xy = start_xy

      if stop.lat > start.lat
        i = start_xy[1] + 1
        while i <= stop_xy[1]
          edge_point = get_grid_intersect(start, brng, @lat_grid[i])
          edge_xy = get_grid_coords_from_hint(edge_point, hint, hint_xy)
          fill_in_grid_squares(hint_xy[0], edge_xy[0], i - 1)
          hint = edge_point
          hint_xy = edge_xy
          i += 1
        end

        fill_in_grid_squares(hint_xy[0], stop_xy[0], i - 1)
      else
        i = start_xy[1]
        while i > stop_xy[1]
          edge_point = get_grid_intersect(start, brng, @lat_grid[i])
          edge_xy = get_grid_coords_from_hint(edge_point, hint, hint_xy)
          fill_in_grid_squares(hint_xy[0], edge_xy[0], i)
          hint = edge_point
          hint_xy = edge_xy
          i -= 1
        end

        fill_in_grid_squares(hint_xy[0], stop_xy[0], i)
      end
    end

    def get_grid_intersect(start, brng, grid_line_lat)
      d = R * ((deg2rad(grid_line_lat) - deg2rad(start.lat))) / Math.cos(deg2rad(brng))
      start.rhumb_destination_point(brng, d)
    end

    def fill_in_grid_squares(start_x, stop_x, y)
      if start_x < stop_x
        x = start_x
        while x <= stop_x
          mark_cell([x, y])
          x += 1
        end
      else
        x = start_x
        while x >= stop_x
          mark_cell([x, y])
          x -= 1
        end
      end
    end

    def mark_cell(cell)
      x = cell[0]
      y = cell[1]
      @grid[x - 1][y - 1] = 1
      @grid[x][y - 1] = 1
      @grid[x + 1][y - 1] = 1
      @grid[x - 1][y] = 1
      @grid[x][y] = 1
      @grid[x + 1][y] = 1
      @grid[x - 1][y + 1] = 1
      @grid[x][y + 1] = 1
      @grid[x + 1][y + 1] = 1
      @grid
    end

    def merge_intersecting_cells
      current_box = nil

      y = 0
      while y < @grid[0].length
        x = 0
        while x < @grid.length
          if @grid[x][y]
            box = get_cell_bounds([x, y])
            if current_box
              current_box.extend(box.get_north_east)
            else
              current_box = box
            end
          else
            merge_boxes_y(current_box)
            current_box = nil
          end

          x += 1
        end

        merge_boxes_y(current_box)
        current_box = nil

        y += 1
      end

      x = 0

      while x < @grid.length
        y = 0
        while y < @grid[0].length
          if @grid[x][y]
            if current_box
              box = get_cell_bounds([x, y])
              current_box.extend(box.get_north_east)
            else
              current_box = get_cell_bounds([x, y])
            end
          else
            merge_boxes_x(current_box)
            current_box = nil
          end
          y += 1
        end

        merge_boxes_x(current_box)
        current_box = nil

        x += 1
      end
    end

    def merge_boxes_x(box)
      if box != nil
        i = 0
        while i < @boxes_x.length
          if @boxes_x[i].get_north_east.lng == box.get_south_west.lng &&
              @boxes_x[i].south_west.lat == box.south_west.lat &&
              @boxes_x[i].get_north_east.lat == box.get_north_east.lat

            @boxes_x[i].extend(box.get_north_east)
            return
          end
          i += 1
        end
        @boxes_x << box
      end
    end

    def merge_boxes_y(box)
      if box != nil
        i = 0
        while i < @boxes_y.length
          if @boxes_y[i].get_north_east.lat == box.get_south_west.lat &&
              @boxes_y[i].get_south_west.lng == box.get_south_west.lng &&
              @boxes_y[i].get_north_east.lng == box.get_north_east.lng

            @boxes_y[i].extend(box.get_north_east)
            return
          end

          i += 1
        end
        @boxes_y << box
      end
    end

    def get_cell_bounds(cell)
      south_west = RouteBoxer::LatLng.new(@lat_grid[cell[1]], @lng_grid[cell[0]])
      north_east = RouteBoxer::LatLng.new(@lat_grid[cell[1] + 1], @lng_grid[cell[0] + 1])
      return RouteBoxer::LatLngBounds.new(south_west, north_east)
    end
  end
end

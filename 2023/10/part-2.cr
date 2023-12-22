module AOC
  extend self

  alias Grid = Array(Array(Char))
  alias Point = Tuple(Int32, Int32)

  def main
    grid, starting_point = read_input
    points = trace_path(grid, starting_point)
    enclosed = points_enclosed_by_path(grid, points)
    print_path(grid, points, enclosed)
    puts(enclosed.size)
  end

  def read_input : Tuple(Grid, Point)
    lines = STDIN
      .each_line
      .zip(1..)

    lines.reduce({[] of Array(Char), {0, 0}}) do |accum, line|
      grid, starting_point = accum
      line, line_number = line

      chars = line.chars
      grid << chars

      start_xoffset = chars.index('S')
      next {grid, starting_point} if start_xoffset.nil?

      {grid, {start_xoffset, line_number}}
    end
  end

  def trace_path(grid : Grid, current : Point, visited : Set(Point)? = nil) : Set(Point)
    visited ||= Set(Point).new

    visited << current
    destination = point_destinations(grid, current).find { |point| !visited.includes?(point) }
    return visited if destination.nil?

    trace_path(grid, destination, visited)
  end

  def point_destinations(grid, point : Point) : Array(Point)
    x, y = point

    destinations =
      case grid[y][x]
      when '|' then [{x, y - 1}, {x, y + 1}]
      when '-' then [{x - 1, y}, {x + 1, y}]
      when 'L' then [{x, y - 1}, {x + 1, y}]
      when 'J' then [{x - 1, y}, {x, y - 1}]
      when '7' then [{x - 1, y}, {x, y + 1}]
      when 'F' then [{x, y + 1}, {x + 1, y}]
      when '.' then [] of Point
      when 'S' then [{x - 1, y}, {x + 1, y}, {x, y - 1}, {x, y + 1}]
      else          raise "Invalid pipe: #{grid[y][x]}"
      end

    if grid[y][x] == 'S'
      destinations = destinations.select { |destination| point_destinations(grid, destination).includes?(point) }
    end

    destinations
      .select { |dest_x, dest_y| (0...grid[0].size).includes?(dest_x) && (0...grid.size).includes?(dest_y) }
  end

  def points_enclosed_by_path(grid : Grid, path_points : Set(Point)) : Set(Point)
    enclosed_points = Set(Point).new

    (0...grid.size).each do |y|
      (0...grid[y].size).each do |x|
        point = {x, y}
        next if path_points.includes?(point)

        if point_enclosed?(grid, path_points, point)
          enclosed_points << point
        end
      end
    end

    enclosed_points
  end

  def point_enclosed?(grid, path_points : Set(Point), point : Point) : Bool
    path = [] of Point

    curves =
      (0...point[1]).reduce(0) do |crossed_curves, y|
        ray_point = {point[0], y}

        if path_points.includes?(ray_point)
          if !path.empty?
            if point_destinations(grid, path[-1]).includes?(ray_point)
              path << ray_point
              next crossed_curves
            end

            crossed_curves += path_forms_turn?(grid, path) ? 2 : 1
            path.clear
          end

          path << ray_point
        elsif !path.empty?
          crossed_curves += path_forms_turn?(grid, path) ? 2 : 1
          path.clear
        end

        crossed_curves
      end

    curves += path_forms_turn?(grid, path) ? 2 : 1 if !path.empty?
    curves.odd?
  end

  def path_forms_turn?(grid : Grid, path : Array(Point)) : Bool
    return false if path.size <= 1

    x1 = point_destinations(grid, path[0]).find { |x, _| x != path[0][0] }
    x2 = point_destinations(grid, path[-1]).find { |x, _| x != path[0][0] }

    raise "Broken path provided" if x1.nil? || x2.nil?

    x1[0] == x2[0]
  end

  def print_path(grid : Grid, path : Set(Point), enclosed : Set(Point))
    (0...grid.size).each do |y|
      (0...grid[y].size).each do |x|
        if path.includes?({x, y})
          print(grid[y][x])
        elsif enclosed.includes?({x, y})
          print("@")
        else
          print('.')
        end
      end

      puts
    end
  end
end

AOC.main

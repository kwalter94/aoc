module AOC
  extend self

  alias Point = Tuple(Int32, Int32)
  alias Grid = Array(Array(Char))

  def main
    grid, starting_point = read_input
    points = trace_path(grid, starting_point)
    furthest_point_steps = points.size // 2
    furthest_point_steps += 1 if points.size.odd?
    puts(furthest_point_steps)
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
end

AOC.main

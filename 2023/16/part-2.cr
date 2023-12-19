alias Grid = Array(Array(Char))
alias Point = Tuple(Int32, Int32)
alias Direction = Tuple(Int32, Int32)

struct Graph
  property nodes : Hash(Point, Array(Point))
  property points : Set(Point)

  def initialize
    @nodes = {} of Point => Array(Point)
    @points = Set(Point).new
  end

  def add_node(point : Point, branch : Point)
    @nodes[point] ||= [] of Point
    @points << point

    @nodes[point] << branch
    @nodes[branch] ||= [] of Point
    @points << branch
  end

  def print_points(grid_width : Int32, grid_height : Int32)
    (0...grid_height).each do |y|
      (0...grid_width).each do |x|
        if @points.includes?({x, y})
          print('#')
        else
          print('.')
        end
      end

      puts
    end
  end

  def size
    @points.size
  end
end

def main
  grid = read_input
  frames = starting_frames(grid)

  ch = Channel(Graph).new
  workers = ENV.fetch("CRYSTAL_WORKERS", "10").to_i32
  batch_size = frames.size // workers

  (0...frames.size)
    .step(by: batch_size)
    .each { |start| find_graph_with_max_frames(ch, grid, frames[start...(start + batch_size)]) }

  max_graph =
    (0...workers)
      .map { ch.receive }
      .max_by { |graph| graph.size }
  ch.close

  max_graph.print_points(grid[0].size, grid.size)
  puts(max_graph.size)
end

def read_input : Grid
  STDIN.each_line.each_with_object([] of Array(Char)) do |line, grid|
    next if line.empty?

    grid << line.chars
  end
end

def starting_frames(grid : Grid) : Array(Tuple(Point, Direction))
  frames = [] of Tuple(Point, Direction)

  (0...grid[0].size).each do |x|
    frames << { {x, 0}, {0, 1} }
    frames << { {x, grid.size - 1}, {0, -1} }
  end

  (0...grid.size).each do |y|
    frames << { {0, y}, {1, 0} }
    frames << { {grid[0].size - 1, y}, {-1, 0} }
  end

  frames
end

def find_graph_with_max_frames(ch : Channel(Graph), grid : Grid, frames : Enumerable(Tuple(Point, Direction)))
  spawn do
    graph =
      frames
        .map { |frame| traverse_grid(grid, frame[0], frame[1], Graph.new) }
        .max_by { |graph| graph.size }

    ch.send(graph)
  end
end

def traverse_grid(grid : Grid, point : Point, dxdy : Direction) : Graph
  paths = Graph.new
  traverse_grid(grid, point, dxdy, paths)
end

def traverse_grid(grid : Grid, point : Point, dxdy : Direction, graph : Graph) : Graph
  x, y = point
  dx, dy = dxdy

  diffs =
    case grid[y][x]
    when '|'
      dx != 0 ? [{0, -1}, {0, 1}] : [dxdy]
    when '-'
      dy != 0 ? [{-1, 0}, {1, 0}] : [dxdy]
    when '/'
      if dx == -1
        [{0, 1}]
      elsif dx == 1
        [{0, -1}]
      elsif dy == -1
        [{1, 0}]
      else
        [{-1, 0}]
      end
    when '\\'
      if dx == -1
        [{0, -1}]
      elsif dx == 1
        [{0, 1}]
      elsif dy == -1
        [{-1, 0}]
      else
        [{1, 0}]
      end
    else
      [dxdy]
    end

  diffs = [dxdy] if point == {0, 0}

  diffs.each do |diff|
    new_point = {x + diff[0], y + diff[1]}
    next if graph.nodes.has_key?(point) && graph.nodes[point].includes?(new_point)

    next if (new_point[0] < 0 || new_point[0] >= grid[0].size) || (new_point[1] < 0 || new_point[1] >= grid.size)

    graph.add_node(point, new_point)
    traverse_grid(grid, new_point, diff, graph)
  end

  graph
end

main

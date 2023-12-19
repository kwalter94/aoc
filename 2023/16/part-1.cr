alias Grid = Array(Array(Char))
alias Point = Tuple(Int32, Int32)

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
  graph = traverse_grid(grid, {0, 0}, {1, 0})
  graph.print_points(grid[0].size, grid.size)
  puts(graph.size)
end

def read_input : Grid
  STDIN.each_line.each_with_object([] of Array(Char)) do |line, grid|
    next if line.empty?

    grid << line.chars
  end
end

def traverse_grid(grid : Grid, point : Point, dxdy : Tuple(Int32, Int32)) : Graph
  paths = Graph.new
  traverse_grid(grid, point, dxdy, paths)
end

def traverse_grid(grid : Grid, point : Point, dxdy : Tuple(Int32, Int32), graph : Graph) : Graph
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
    pp(diffs) if point == {0, 0}
    new_point = {x + diff[0], y + diff[1]}
    next if graph.nodes.has_key?(point) && graph.nodes[point].includes?(new_point)

    next if (new_point[0] < 0 || new_point[0] >= grid[0].size) || (new_point[1] < 0 || new_point[1] >= grid.size)

    graph.add_node(point, new_point)
    traverse_grid(grid, new_point, diff, graph)
  end

  graph
end

main

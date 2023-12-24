module AOC
  extend self

  enum ReflectionType
    Horizontal
    Vertical
  end

  alias Grid = Array(Array(Char))
  alias Point = Tuple(Int32, Int32)
  alias Reflection = Tuple(ReflectionType, Point)

  class Input
    include Enumerable(Grid)

    def each(&)
      grid = Array(Array(Char)).new

      STDIN.each_line do |line|
        if line.blank?
          yield grid.dup
          grid.clear
          next
        end

        grid << line.chars
      end

      yield grid unless grid.empty?
    end
  end

  def main
    reflected_lines =
      Input
        .new
        .map { |grid| find_reflection_line(grid) }
        .tap { |reflection| pp({:reflection, reflection}) }
        .each_with_object({} of ReflectionType => Int32) do |reflection, accum|
          next if reflection.nil?
          
          type, point = reflection
          accum[type] ||= 0
          accum[type] += (point[0] + point[1]) + 1 # One of x and y is always 0
        end

    total = reflected_lines.fetch(ReflectionType::Vertical, 0) + (100 * reflected_lines.fetch(ReflectionType::Horizontal, 0))
    puts(total)
  end

  def find_reflection_line(grid : Grid) : Reflection?
    reflection = find_horizontal_reflection_line(grid)
    reflection = find_vertical_reflection_line(grid) if reflection.nil?

    reflection
  end

  def find_horizontal_reflection_line(grid : Grid) : Reflection?
    (0...(grid.size - 1)).each do |y|
      point = {0, y}
      return {ReflectionType::Horizontal, point} if perfect_horizontal_reflection?(grid, point)
    end
  end

  def perfect_horizontal_reflection?(grid : Grid, point : Point) : Bool
    y1 = point[1]
    y2 = y1 + 1
    allotted_smudges = [1]

    while y1 >= 0 && y2 < grid.size
      rows_matching = (0...grid[y1].size).all? do |x|
        next true if grid[y1][x] == grid[y2][x]

        next false if allotted_smudges.empty?

        allotted_smudges.pop
        true
      end

      return false unless rows_matching

      y1 -= 1
      y2 += 1
    end

    allotted_smudges.empty?
  end

  def find_vertical_reflection_line(grid : Grid) : Reflection?
    (0...(grid[0].size - 1)).each do |x|
      point = {x, 0}
      return {ReflectionType::Vertical, point} if perfect_vertical_reflection?(grid, point)
    end
  end

  def perfect_vertical_reflection?(grid : Grid, point : Point) : Bool
    x1 = point[0]
    x2 = x1 + 1
    allotted_smudges = [1]

    while x1 >= 0 && x2 < grid[0].size
      columns_matching = (0...grid.size).all? do |y|
        next true if grid[y][x1] == grid[y][x2]

        next false if allotted_smudges.empty?

        allotted_smudges.pop
        true
      end

      return false unless columns_matching

      x1 -= 1
      x2 += 1
    end

    allotted_smudges.empty?
  end

  def pprint_grid(grid : Grid)
    grid.each do |row|
      row.each { |item| print(item) }
      puts
    end
  end

  main
end


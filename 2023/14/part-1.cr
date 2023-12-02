module AOC
  extend self

  alias Grid = Array(Array(Char))

  def main
    grid = read_input
    tilt_grid!(grid)
    load = calculate_total_load(grid)

    puts(load)
  end

  def read_input : Grid
    STDIN.each_line.each_with_object([] of Array(Char)) do |line, grid|
      grid << line.chars
    end
  end

  def tilt_grid!(grid : Grid)
    (0...grid[0].size).each do |x|
      free_y = 0
      y = 1

      while free_y < grid.size
        while free_y < grid.size && grid[free_y][x] != '.'
          free_y += 1
        end

        y = free_y + 1 if y <= free_y
        break if y >= grid.size

        case grid[y][x]
        when '#'
          free_y = y + 1
          y += 2
        when '.'
          y += 1
        else
          grid[free_y][x] = 'O'
          grid[y][x] = '.'
       
          free_y += 1
          y += 1
        end
      end
    end
  end

  def calculate_total_load(grid : Grid) : Int32
    grid
      .zip((1...(grid.size + 1)).reverse_each)
      .reduce(0) do |accum, row_params|
        row, value = row_params
        accum + (row.count('O') * value)
      end
  end

  main
end

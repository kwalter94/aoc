module AOC
  extend self

  alias Grid = Array(Array(Char))

  def main
    initial_grid = read_input
    final_grid = tilt_grid(initial_grid)
    load = calculate_total_load(final_grid)

    puts(load)
  end

  def read_input : Grid
    STDIN.each_line.each_with_object([] of Array(Char)) do |line, grid|
      grid << line.chars
    end
  end

  alias Visit = Tuple(Symbol, UInt64)

  MAX_SPINS = 1_000_000_000

  def tilt_grid(grid : Grid, max_spins = MAX_SPINS) : Grid
    visited = Hash(Tuple(Symbol, UInt64), Grid).new
    directions = [:north, :west, :south, :east]
    tilts = 0
    spins = 1
    cycle_start : Tuple(Visit, Int32)? = nil

    loop do
      return grid if spins == max_spins

      direction = directions[tilts % directions.size]
      visit = {direction, grid_hash(grid)}

      new_grid =
        case direction
        when :north then tilt_north(grid)
        when :west then tilt_west(grid)
        when :south then tilt_south(grid)
        when :east then tilt_east(grid)
        else raise "WTF was that? #{direction}"
        end
      
      if direction == :north && visited.has_key?(visit) && equal_grids?(visited[visit], new_grid)
        pp({:cycle_detected, {:visit, visit}, {:cycle_start, cycle_start}, {:cycle, spins}})
        if cycle_start && visit == cycle_start[0] && max_spins == MAX_SPINS
          cycle_length = spins - cycle_start[1]
          old_max_spins = max_spins
          max_spins = spins + (((max_spins  - spins) % cycle_length) + cycle_length) - 1
          pp({:adjusted_target_spins, {:from, old_max_spins}, {:to, max_spins}})
        elsif cycle_start.nil?
          cycle_start = {visit, spins}
        end
      end

      grid = visited[visit] = new_grid
      tilts += 1
      spins += 1 if directions[tilts % directions.size] == :north
    end
  end

  def tilt_north(grid : Grid) : Grid
    grid = dup_grid(grid)

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

    grid
  end

  def tilt_west(grid : Grid) : Grid
    grid = dup_grid(grid)

    (0...grid.size).each do |y|
      free_x = 0
      x = 1

      while free_x < grid[y].size
        while free_x < grid[y].size && grid[y][free_x] != '.'
          free_x += 1
        end

        x = free_x + 1 if x <= free_x
        break if x >= grid[y].size

        case grid[y][x]
        when '#'
          free_x = x + 1
          x += 2
        when '.'
          x += 1
        else
          grid[y][free_x] = 'O'
          grid[y][x] = '.'
       
          free_x += 1
          x += 1
        end
      end
    end

    grid
  end

  def tilt_south(grid : Grid) : Grid
    grid = dup_grid(grid)

    (0...grid[0].size).each do |x|
      free_y = grid.size - 1
      y = free_y - 1

      while free_y >= 0
        while free_y >= 0 && grid[free_y][x] != '.'
          free_y -= 1
        end

        y = free_y - 1 if y >= free_y
        break if y < 0

        case grid[y][x]
        when '#'
          free_y = y - 1
          y -= 2
        when '.'
          y -= 1
        else
          grid[free_y][x] = 'O'
          grid[y][x] = '.'
       
          free_y -= 1
          y -= 1
        end
      end
    end

    grid
  end

  def tilt_east(grid : Grid) : Grid
    grid = dup_grid(grid)

    (0...grid.size).each do |y|
      free_x = grid[y].size - 1
      x = free_x - 1

      while free_x >= 0
        while free_x >= 0 && grid[y][free_x] != '.'
          free_x -= 1
        end

        x = free_x - 1 if x >= free_x
        break if x < 0

        case grid[y][x]
        when '#'
          free_x = x - 1
          x -= 2
        when '.'
          x -= 1
        else
          grid[y][free_x] = 'O'
          grid[y][x] = '.'
       
          free_x -= 1
          x -= 1
        end
      end
    end

    grid

  end

  def dup_grid(grid : Grid) : Grid
    copy = [] of Array(Char)
    grid.each { |row| copy << row.dup }
    copy
  end

  def grid_hash(grid : Grid) : UInt64
    grid.map(&.join).join.hash
  end

  def equal_grids?(left : Grid, right : Grid) : Bool
    (0...left.size).each do |y|
      (0...left[y].size).each do |x|
        return false if left[y][x] != right[y][x]
      end
    end

    true
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

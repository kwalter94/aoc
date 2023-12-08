module AOC
  extend self

  def traverse_path(path)
    path = path.chars

    Enumerator.new do |enum|
      offset = 0

      loop do
        offset = 0 if offset >= path.size
        enum.yield path[offset]

        offset += 1
      end
    end
  end

  def read_input
    path = STDIN.gets&.strip
    raise "Invalid input" if path.nil?

    map = {}

    STDIN.each_line do |line|
      next if line.empty?

      match = /(?<source>\w+) = \((?<left>\w+), (?<right>\w+)\)/.match(line)
      next if match.nil?

      map[match["source"]] = [match["left"], match["right"]]
    end

    [path, map]
  end

  def count_steps_in_path(path, map, point)
    traverse_path(path).reduce(0) do |steps, direction|
      break steps if point.end_with?('Z')

      left, right = map[point]

      case direction
      when 'L' then point = left
      when 'R' then point = right
      else raise "Invalid direction: #{direction}"
      end

      steps + 1
    end
  end

  def lcm(numbers)
    f_gcd = ->(a, b) do 
      while b > 0
        a, b = b, (a % b)
      end

      a
    end

    numbers[1...].reduce(numbers[0]) do |accum, number|
      accum * number / f_gcd.call(accum, number)
    end
  end
end

path, map = AOC.read_input
points = map.keys.select { |point| point.end_with?('A') }
steps = points.map { |point| AOC.count_steps_in_path(path, map, point) }
puts(AOC.lcm(steps))

module AOC
  extend self

  alias Map = Hash(String, Tuple(String, String))

  class Path
    include Enumerable(Char)

    @path : Array(Char)

    def initialize(path : String)
      @path = path.chars
    end

    def each(&)
      offset = 0

      loop do
        offset = 0 if offset >= @path.size
        yield @path[offset]

        offset += 1
      end
    end
  end

  def read_input : Tuple(Path, Map)
    path = STDIN.gets.try(&.strip)
    raise "Invalid input" if path.nil?

    starting_point = [] of String
    map = {} of String => Tuple(String, String)

    STDIN.each_line do |line|
      next if line.blank?

      match = /(?<source>\w+) = \((?<left>\w+), (?<right>\w+)\)/.match(line)
      next if match.nil?

      map[match["source"]] = {match["left"], match["right"]}
    end

    {Path.new(path), map}
  end

  def count_steps_in_path(path : Path, map : Map, starting_point : String) : Int64
    point = starting_point
    last_z_steps = 0

    path.reduce(0.to_i64) do |steps, direction|
      if point.ends_with?('Z')
        break steps if last_z_steps == steps

        puts("Resetting cycle...")
        last_z_steps = steps
        steps = 0.to_i64
      end

      left, right = map[point]

      case direction
      when 'L' then point = left
      when 'R' then point = right
      else raise "Invalid direction: #{direction}"
      end

      steps + 1
    end
  end

  def lcm(numbers : Array(Int64 | Int32)) : Int64
    f_gcd = ->(a : Int64, b : Int64) : Int64 do 
      while b > 0
        a, b = b, (a % b)
      end

      a
    end

    numbers[1...].reduce(numbers[0].to_i64) do |accum, number|
      number = number.to_i64
      accum * number // f_gcd.call(accum, number)
    end
  end
end

path, map = AOC.read_input
points = map.keys.select { |point| point.ends_with?('A') }
steps = points.map { |point| AOC.count_steps_in_path(path, map, point) }
puts(AOC.lcm(steps))

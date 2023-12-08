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
    path = STDIN.gets
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

  def count_steps_in_path(path : Path, map : Map) : Int32
    point = "AAA"

    path.reduce(0) do |steps, direction|
      return steps if point == "ZZZ"

      junction = map[point]
      case direction
      when 'L' then point = junction[0]
      when 'R' then point = junction[1]
      else raise "Invalid direction: #{direction}"
      end

      steps + 1
    end
  end
end

path, map = AOC.read_input
steps = AOC.count_steps_in_path(path, map)
puts(steps)

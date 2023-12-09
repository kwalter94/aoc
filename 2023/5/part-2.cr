module AOC
  extend self

  struct Range
    property start : Int64
    property size : Int64

    def initialize(@start, @size); end

    def last : Int64
      @start + @size - 1
    end

    def intersect?(other : Range) : Bool
      (self.start <= other.start && self.last >= other.start) \
        || (self.start >= other.start && self.start <= other.last)
    end

    # Get how much of other range that is contained within this range
    # and how much isn't.
    #
    # Returns a tuple of the following structure:
    #   {<not matched on the left>, <matched>, <not matched on the right>}
    def map_range(other : Range) : Tuple(Range?, Range?, Range?)
      if self.start <= other.start && self.last >= other.last
        # Other is contained within this range
        matched = Range.new(other.start, other.size)
        not_matched_left = nil
        not_matched_right = nil
      elsif self.start <= other.start && self.last >= other.start && self.last <= other.last
        # Other's tail is not contained within this range
        matched = Range.new(other.start, self.last - other.start)
        not_matched_left = nil
        not_matched_right = Range.new(self.last + 1, other.last - self.last + 1)
      elsif self.start >= other.start && self.last <= other.last
        # Other's head and tail are not contained within this range
        matched = Range.new(self.start, self.size)
        not_matched_left = Range.new(other.start, self.start - other.start)
        not_matched_right = Range.new(self.last + 1, other.last - self.last + 1)
      elsif self.start >= other.start && self.start <= other.last && self.last >= other.last
        # Other's head is not contained within this range
        matched = Range.new(self.start, other.last - self.start)
        not_matched_left = Range.new(other.start, self.start - 1)
        not_matched_right = nil
      elsif self.start > other.start
        matched = nil
        not_matched_left = Range.new(other.start, other.size)
        not_matched_right = nil
      else
        matched = nil
        not_matched_left = nil
        not_matched_right = Range.new(other.start, other.size)
      end

      {not_matched_left, matched, not_matched_right}
    end
  end

  struct RangeMapping
    property source : Range
    property destination : Range

    def initialize(@source, @destination); end
  end

  class MappingTable
    def initialize
      @mappings = {} of String => Tuple(String, Array(RangeMapping))
    end

    def add_mapping(
      source_name : String,
      source_start : Int64,
      destination_name : String,
      destination_start : Int64,
      range_size : Int64
    )
      source_range = Range.new(source_start, range_size)
      destination_range = Range.new(destination_start, range_size)
      @mappings[source_name] ||= {destination_name, [] of RangeMapping}
      @mappings[source_name][1] << RangeMapping.new(source_range, destination_range)
    end

    def find_locations(range : Range, source_name : String = "seed") : Range
      destination_name, mappings = @mappings[source_name]
      pp("#{source_name} => #{destination_name}")
      return range if destination_name == "location"

      mappings = mappings.sort_by { |mapping| {mapping.source.start, mapping.source.last} }

      source_ranges = 
        mappings.each_with_object([] of Range) do |mapping, ranges|
          break ranges if range.nil?

          not_matched_left, matched, not_matched_right = mapping.source.map_range(range)
          pp({range, mapping, {not_matched_left, matched, not_matched_right}})
          ranges << not_matched_left if not_matched_left

          if matched
            start = mapping.destination.start + (matched.start - mapping.source.start)
            size = matched.size
            ranges << Range.new(start, size)
          end

          range = not_matched_right
          ranges
        end

      source_ranges << range if range

      pp(source_ranges)
      source_ranges.map { |range| find_locations(range, destination_name) }.min_by { |range| range.start }
    end
  end

  def load_input : Tuple(Array(Range), MappingTable)
    line = STDIN.gets
    raise "Invalid input!" if line.nil?

    _, values = line.split(':')
    values = values.split.map(&.to_i64)
    ranges = [] of AOC::Range

    (0...values.size).step(2) do |i|
      ranges << AOC::Range.new(values[i], values[i + 1])
    end

    destination_name = ""
    source_name = ""

    mapping_table =
      STDIN.each_line.each_with_object(MappingTable.new) do |line, table|
        next if line.blank?

        match = /(?<source>[a-z]+)-to-(?<destination>[a-z]+) map:/.match(line)
        if match
          source_name = match["source"]
          destination_name = match["destination"]
          next
        end

        destination, source, range = line.split.map(&.to_i64)
        table.add_mapping(
          source_name,
          source,
          destination_name,
          destination,
          range,
        )
      end

    {ranges, mapping_table}
  end
end

  
seed_ranges, table = AOC.load_input
location_ranges =
  seed_ranges.map { |range| table.find_locations(range) }

pp(location_ranges)
puts(location_ranges.min_by { |range| range.start })

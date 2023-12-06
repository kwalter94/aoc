line = STDIN.gets
raise "No lines!" if line.nil?

_, seeds = line.split(':')
seeds = seeds.split.map(&.to_i64)

source : String? = nil
destination : String? = nil

struct Mapping
  property destination : String
  property range_maps : Array(Tuple(Int64, Int64, Int64))

  def initialize(@destination, @range_maps); end
end

map = STDIN.each_line.each_with_object({} of String => Mapping) do |line, map|
  next if line.blank?

  match = /(?<source>[a-z]+)-to-(?<destination>[a-z]+) map:/.match(line)
  if match
    destination = match["destination"]
    source = match["source"]

    map[source] = Mapping.new(destination, [] of Tuple(Int64, Int64, Int64))
    next
  end

  destination_start, source_start, range_size = line.split.map(&.to_i64)
  map[source].range_maps << {destination_start, source_start, range_size}
end

def dig_location(map : Hash(String, Mapping), source : String, value : Int64) : Int64?
  map[source].range_maps.each do |range_map|
    pp({source, value, range_map})
    destination_start, source_start, range_size = range_map
    next if value < source_start || value > source_start + range_size

    mapped_value = destination_start + (value - source_start)
    return mapped_value if map[source].destination == "location"
    
    return dig_location(map, map[source].destination, mapped_value)
  end

  return value if map[source].destination == "location"

  dig_location(map, map[source].destination, value)
end


value = (seeds.map { |seed| dig_location(map, "seed", seed) }).min
puts("Value: #{value}")

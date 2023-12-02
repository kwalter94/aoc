def find_better_races(race_time : Int64, max_distance : Int64) : Array(Int64)
  (1...race_time).each_with_object([] of Int64) do |i, races|
    distance = (race_time - i) * i
    next unless distance > max_distance

    races << distance
  end
end


input = STDIN.each_line.each_with_object({} of String => Int64) do |line, accum|
  next if line.blank?

  field, value = line.split(":")
  accum[field] = value.gsub(/\s+/, "").to_i64
end

value = find_better_races(input["Time"], input["Distance"]).size
puts(value)





def find_better_races(race_time : Int64, max_distance : Int64) : Array(Int64)
  (1...race_time).each_with_object([] of Int64) do |i, races|
    distance = (race_time - i) * i
    next unless distance > max_distance

    races << distance
  end
end


input = STDIN.each_line.each_with_object({} of String => Array(Int64)) do |line, accum|
  next if line.blank?

  field, value = line.split(":")
  accum[field] = value.split.map(&.to_i64)
end

race_records = input["Time"].each.zip(input["Distance"].each)
value = race_records.reduce(1) do |accum, record|
  find_better_races(record[0], record[1]).size * accum
end

puts(value)





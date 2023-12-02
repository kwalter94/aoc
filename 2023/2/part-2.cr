def game_min_power(game : Array(String)) : Int32
  counts = game.reduce({"red" => 0, "blue" => 0, "green" => 0}) do |accum, rounds|
    rounds.split(";").each do |picks|
      picks.split(",").each do |pick|
        count, colour = pick.split
        next if accum.nil?

        accum[colour] = count.to_i if accum[colour] < count.to_i
      end
    end

    accum
  end

  return 0 if counts.nil?

  counts.values.reduce(1) { |accum, v| v * accum }
end

value = STDIN.each_line.reduce(0) do |accum, line|
  _, game = line.split(":")

  accum + game_min_power(game.strip.split(","))
end

puts "Value: #{value}"

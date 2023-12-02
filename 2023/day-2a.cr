CUBES = {
  "red"   => 12,
  "green" => 13,
  "blue"  => 14,
}

def valid_game?(game : Array(String)) : Bool
  game.each do |picks|
    picks.split(",").each do |pick|
      count, colour = pick.split
      return false if CUBES[colour] < count.to_i
    end
  end

  true
end

value = STDIN.each_line.reduce(0) do |accum, line|
  game_number, game = line.split(":")
  _, game_number = game_number.split

  accum + (valid_game?(game.split(";")) ? game_number.to_i : 0)
end

puts("Value: #{value}")

value = STDIN.each_line.reduce(0) do |accum, line|
  _, card = line.split(":")
  winning, in_hand = card.strip.split("|")
  winning_lookup = Set(String).new(winning.strip.split.map(&.strip))

  matches = in_hand.split.select do |number|
    winning_lookup.includes?(number.strip)
  end

  accum + (matches.size.zero? ? 0 : 2 ** (matches.size - 1))
end

puts(value)

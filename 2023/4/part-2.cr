card_counts = [0] of Int32

STDIN.each_line.each_with_index do |line, i|
  _, card = line.split(":")
  winning, in_hand = card.strip.split("|")
  winning_lookup = Set(String).new(winning.strip.split.map(&.strip))

  matches = in_hand.split.select do |number|
    winning_lookup.includes?(number.strip)
  end

  card_counts[i] += 1

  extra_slots = (i + matches.size) - card_counts.size
  (0..(extra_slots + 1)).each { card_counts << 0 }

  matches.each_with_index do |_, j|
    card_counts[i + j + 1] += 1 * card_counts[i]
  end
end

value = card_counts.reduce(0) { |accum, value| value + accum } 

puts("Value: #{value}")

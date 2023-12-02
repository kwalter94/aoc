value = STDIN.each_line.reduce(0) do |accum, line|
  digits = [] of Int32

  line.each_char do |char|
    next unless char.number?

    digits << char.to_i32
  end

  accum + (digits[0] * 10) + digits[-1]
end

puts("Value: #{value}")

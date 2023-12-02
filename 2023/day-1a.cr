value = STDIN.each_line.reduce(0) do |accum, line|
  digits = [] of Int32

  line.each_char do |char|
    next unless char.number?

    if digits.size < 2
      digits << char.to_i32
    else
      digits[1] = char.to_i32
    end
  end

  accum + (digits[0] * 10) + (digits.size == 2 ? digits[1] : digits[0])
end

puts("Value: #{value}")

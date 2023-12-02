DIGITS = ["one", "two", "three", "four", "five", "six", "seven", "eight", "nine"]

value = STDIN.each_line.reduce(0) do |accum, line|
  numbers = (0...line.size).each_with_object([] of Int32) do |i, numbers|
    if line[i].try(&.number?)
      numbers << line[i].to_i32
      next
    end

    DIGITS.each_with_index do |digit, index|
      if line[i, digit.size] == digit
        numbers << index + 1
        break
      end
    end
  end

  current_value = numbers[0] * 10 + numbers[-1]
  accum + current_value
end

puts("Value: #{value}")

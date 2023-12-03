SYMBOL = -1
BLANK = -2

def next_line : Array(Int32)?
  line = STDIN.gets
  return nil if line.nil?

  line.each_char.each_with_object([] of Int32) do |char, buf|
    if char.number?
      buf << char.to_i32
    elsif char == '*'
      buf << SYMBOL
    else
      buf << BLANK
    end
  end
end

buf = [] of Array(Int32)
buf_width = -1
done = false
line_number = 1
gears = {} of Tuple(Int32, Int32) => Array(Int32)

while !done
  line = next_line
  if line.nil?
    done = true
    line = Array(Int32).new(buf_width, BLANK)
  end

  buf_width = line.size if buf_width == -1

  buf << Array(Int32).new(buf_width, BLANK) if buf.size == 0
  buf << line
  next if buf.size < 3

  current_number = 0
  matching_gears = Set(Tuple(Int32, Int32)).new

  buf[1].each_with_index do |value, i|
    if value < 0
      matching_gears.each do |gear|
        gears[gear] = [] of Int32 unless gears.has_key?(gear)
        gears[gear] << current_number
      end

      current_number = 0
      matching_gears.clear
      next
    end

    current_number = current_number * 10 + value

    matching_gears << {line_number, i} if i > 0 && buf[1][i - 1] == SYMBOL
    matching_gears << {line_number, i + 1} if i < buf[1].size - 1 && buf[1][i + 1] == SYMBOL
    matching_gears << {line_number, i - 1} if i > 0 && buf[1][i - 1] == SYMBOL

    matching_gears << {line_number - 1, i} if buf[0][i] == SYMBOL
    matching_gears << {line_number - 1, i - 1} if i > 0 && buf[0][i - 1] == SYMBOL
    matching_gears << {line_number - 1, i + 1} if i < buf[0].size - 1 && buf[0][i + 1] == SYMBOL

    matching_gears << {line_number + 1, i} if buf[2][i] == SYMBOL
    matching_gears << {line_number + 1, i - 1} if i > 0 && buf[2][i - 1] == SYMBOL
    matching_gears << {line_number + 1, i + 1} if i < buf[2].size - 1 && buf[2][i + 1] == SYMBOL
  end

  matching_gears.each do |gear|
    gears[gear] = [] of Int32 unless gears.has_key?(gear)
    gears[gear] << current_number
  end

  buf.shift
  line_number += 1
end

total_value =
  gears
  .values
  .each
  .select { |values| values.size == 2 }
  .map { |values| values[0] * values[1] }
  .reduce(0) { |accum, value| accum + value }

puts("Total value: #{total_value}")

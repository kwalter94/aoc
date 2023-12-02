SYMBOL = -1
BLANK = -2

def next_line : Array(Int32)?
  line = STDIN.gets
  return nil if line.nil?

  line.each_char.each_with_object([] of Int32) do |char, buf|
    if char.number?
      buf << char.to_i32
    elsif char == '.'
      buf << BLANK
    else
      buf << SYMBOL
    end
  end
end

buf = [] of Array(Int32)
buf_width = -1
done = false
total_value = 0

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
  is_adjacent = false

  buf[1].each_with_index do |value, i|
    if value < 0
      total_value += current_number if is_adjacent
      current_number = 0
      is_adjacent = false
      next
    end

    current_number = current_number * 10 + value
    next if is_adjacent

    is_adjacent =
      (i > 0 && buf[1][i - 1] == SYMBOL) \
      || (i < buf[1].size - 1 && buf[1][i + 1] == SYMBOL) \
      || (buf[0][i] == SYMBOL) \
      || (i > 0 && buf[0][i - 1] == SYMBOL) \
      || (i < buf[0].size - 1 && buf[0][i + 1] == SYMBOL) \
      || (buf[2][i] == SYMBOL) \
      || (i > 0 && buf[2][i - 1] == SYMBOL) \
      || (i < buf[2].size - 1 && buf[2][i + 1] == SYMBOL)
  end

  total_value += current_number if is_adjacent
  buf.shift
end

puts("Value: #{total_value}")

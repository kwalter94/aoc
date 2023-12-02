def array_deltas(numbers : Array(Int64)) : Array(Int64)
  (1...numbers.size).each_with_object([] of Int64) do |i, dxs|
    dxs << numbers[i] - numbers[i - 1]
  end
end

def extrapolate_array(numbers : Array(Int64)) : Int64
  pp(numbers)
  return 0.to_i64 if numbers.all?(&.zero?)

  extrapolate_array(array_deltas(numbers)) + numbers[-1]
end

value =
  STDIN.each_line.reduce(0.to_i64) do |accum, line|
    next accum if line.blank?

    accum + extrapolate_array(line.split.map(&.to_i64))
  end

puts(value)

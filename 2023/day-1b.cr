DIGITS_MAP = {
  "one"   => 1,
  "two"   => 2,
  "three" => 3,
  "four"  => 4,
  "five"  => 5,
  "six"   => 6,
  "seven" => 7,
  "eight" => 8,
  "nine"  => 9,
}

def partial_digit_word?(partial_word) : Bool
  DIGITS_MAP.keys.each do |text|
    return true if text.starts_with?(partial_word)
  end

  false
end

enum Mode
  ReadDigit
  Start
  LookAhead
end

struct ParseState
  property mode : Mode
  property digits : Array(Int32)
  property chars : Array(String)

  def initialize
    @mode = Mode::Start
    @chars = [] of String
    @digits = [] of Int32
  end

  def word : String
    String.build do |builder|
      @chars.each { |letter| builder << letter }
    end
  end

  def reset_mode!
    @mode = Mode::Start
    @chars = [] of String
  end

  def store_digit(digit : Int32)
    if @digits.size < 2
      @digits << digit
    else
      @digits[1] = digit
    end
  end
end

value = STDIN.each_line.reduce(0) do |accum, line|
  state = ParseState.new
  chars = line.downcase.chars
  i = 0

  while i < chars.size
    char = chars[i].to_s
    i += 1

    if char.matches?(/\d/)
      state.store_digit(char.to_i32)
      state.reset_mode!
      next
    end

    case state.mode
    when Mode::Start
      next unless "otfsen".includes?(char)

      state.chars << char
      state.mode = "tfs".includes?(char) ? Mode::LookAhead : Mode::ReadDigit
    when Mode::ReadDigit
      state.chars << char
      digit = DIGITS_MAP.fetch(state.word, nil)
      if digit
        state.store_digit(digit)
        state.reset_mode!
        i -= 1
      elsif !partial_digit_word?(state.word)
        i -= state.chars.size - 1
        state.reset_mode!
      end
    when Mode::LookAhead
      state.chars << char

      if partial_digit_word?(state.word)
        state.mode = Mode::ReadDigit
      else
        state.reset_mode!
        i -= 1 # retry letter
      end
    else
      raise "Impossible state!!!"
    end
  end

  current = state.digits[0] * 10 + (state.digits.size == 2 ? state.digits[1] : state.digits[0])
  accum + current
end

puts("Value: #{value}")

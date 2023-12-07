CARD_STRENGTHS = ['2', '3', '4', '5', '6', '7', '8', '9', 'T', 'J', 'Q', 'K', 'A']

enum HandStrength
  HighCard
  OnePair
  TwoPair
  ThreeOfAKind
  FullHouse
  FourOfAKind
  FiveOfAKind
end

alias Hand = Array(Char)

def card_strength(card : Char) : Int32
  index = CARD_STRENGTHS.index(card)
  return 0 if index.nil?

  index + 1
end

def hand_strength(hand : Hand) : Int32
  counts =
    hand.each_with_object({} of Char => Int32) do |card, counts|
      if counts.has_key?(card)
        counts[card] += 1
      else
        counts[card] = 1
      end
    end

  strength =
    if counts.size == 1
      HandStrength::FiveOfAKind
    elsif counts.size == 2
      counts.values.includes?(4) ? HandStrength::FourOfAKind : HandStrength::FullHouse
    elsif counts.size == 3
      counts.values.includes?(3) ? HandStrength::ThreeOfAKind : HandStrength::TwoPair
    elsif counts.size == 4
      HandStrength::OnePair
    else
      HandStrength::HighCard
    end

  strength.value
end

struct Player
  property hand : Hand
  property bid : Int32

  def initialize(@hand, @bid); end
end

def compare_card_strengths(left_hand : Hand, right_hand : Hand) : Int32
  left_hand.zip(right_hand).each do |left_card, right_card|
    left_strength = card_strength(left_card)
    right_strength = card_strength(right_card)

    return -1 if left_strength < right_strength

    return 1 if left_strength > right_strength
  end

  0
end

def sort_players(players : Array(Player)) : Array(Player)
  players.sort do |left, right|
    left_strength = hand_strength(left.hand)
    right_strength = hand_strength(right.hand)

    if left_strength < right_strength
      -1
    elsif left_strength > right_strength
      1
    else
      compare_card_strengths(left.hand, right.hand)
    end
  end
end

def load_players : Array(Player)
  STDIN.each_line.each_with_object([] of Player) do |line, players|
    next if line.blank?

    cards, bid = line.split
    players << Player.new(cards.chars, bid.to_i32)
  end
end

def main
  total_winnings =
    sort_players(load_players)
      .tap { |players| pp(players) }
      .map_with_index { |player, rank| player.bid * (rank + 1) }
      .reduce(0) { |accum, winnings|  accum + winnings }

  puts(total_winnings)
end

main

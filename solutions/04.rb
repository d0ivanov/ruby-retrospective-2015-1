class Card
  attr_reader :rank, :suit

  def initialize(rank, suit)
    @rank = rank
    @suit = suit
  end

  def to_s
    "#{capitalize_first_letter @rank.to_s} of #{capitalize_first_letter @suit}"
  end

  def ==(other)
    other.class == self.class && state == other.state
  end

  protected

  def state
    [@suit, @rank]
  end

  private

  def capitalize_first_letter(string)
    string[0].capitalize + string[1..string.size]
  end
end

class Deck
  include Enumerable

  def initialize(deck = nil)
    if deck == nil
      @deck = ranks.product(suits).map { |rank, suit| Card.new(rank, suit) }
    else
      @deck = deck.dup
    end
  end

  def each
    return enum_for(:each) unless block_given?
    @deck.each { |card| yield card }
  end

  def size
    @deck.size
  end

  def draw_top_card
    @deck.shift
  end

  def draw_bottom_card
    @deck.pop
  end

  def top_card
    @deck.first
  end

  def bottom_card
    @deck.last
  end

  def shuffle
    loop do
      original_deck = @deck.dup
      shuffled_deck = @deck.shuffle!
      return shuffled_deck if shuffled_deck != original_deck
    end
  end

  def to_s
    @deck.map { |card| card.to_s }.join("\n")
  end

  def deal
    PlayerDeck.new(Deck.new(@deck.sample(rand(srand) % size)))
  end

  def sort
    @deck.sort! do |a, b|
      if suits.index(a.suit) == suits.index(b.suit)
        ranks.index(a.rank) <=> ranks.index(b.rank)
      else
        suits.index(a.suit) <=> suits.index(b.suit)
      end
    end
    @deck.reverse!
  end

  private

  def ranks
    [2, 3, 4, 5, 6, 7, 8, 9, 10, :jack, :queen, :king, :ace]
  end

  def suits
    [:clubs, :diamonds, :hearts, :spades]
  end
end

class PlayerDeck
  def initialize(deck)
    @deck = deck
  end

  def size
    return @deck.size
  end
end

class PlayerWarDeck < PlayerDeck
  def play_card
    @deck.draw_top_card
  end

  def allow_face_up?
    @deck.size <= 3
  end
end

class WarDeck < Deck
  HAND_SIZE = 26

  def deal
    PlayerWarDeck.new(WarDeck.new(@deck.slice!(0...HAND_SIZE)))
  end
end

class PlayerBeloteDeck < PlayerDeck
  def highest_of_suit(suit)
    @deck.sort.select { |card| card.suit == suit }.first
  end

  def belote?
    @deck.group_by { |card| card.suit }.each do |suit, group|
      if group.include?(Card.new(:king, suit)) &&
        group.include?(Card.new(:queen, suit))
        return true
      end
    end
    return false
  end

  def tierce?
    @deck.group_by { |card| card.suit }.values.each do |value|
      return true if consecutive_cards(value.map(&:rank), 3)
    end
    false
  end

  def quarte?
    @deck.group_by { |card| card.suit }.values.each do |value|
      return true if consecutive_cards(value.map(&:rank), 4)
    end
    false
  end

  def quint?
    @deck.group_by { |card| card.suit }.values.each do |value|
      return true if consecutive_cards(value.map(&:rank), 5)
    end
    false
  end

  def carre_of_jacks?
    @deck.map(&:rank).count(:jack) == 4
  end

  def carre_of_nines?
    @deck.map(&:rank).count(9) == 4
  end

  def carre_of_aces?
    @deck.map(&:rank).count(:ace) == 4
  end

  private

  def ranks
    [7, 8, 9, :jack, :queen, :king, 10, :ace]
  end

  def consecutive_cards(cards, count)
    ranks_found = 0
    ranks.each do |rank|
      if cards.include? rank
        ranks_found += 1
      else
        ranks_found = 0
      end
    end
    ranks_found >= count
  end
end

class BeloteDeck < Deck
  HAND_SIZE = 8

  def deal
    PlayerBeloteDeck.new(BeloteDeck.new(@deck.slice!(0...HAND_SIZE)))
  end

  private

  def ranks
    [7, 8, 9, :jack, :queen, :king, 10, :ace]
  end
end

class PlayerSixtySixDeck < PlayerDeck
  def twenty?(trump_suit)
    @deck.group_by { |card| card.suit }.each do |suit, group|
      if group.include?(Card.new(:king, suit)) &&
        group.include?(Card.new(:queen, suit)) && suit != trump_suit
        return true
      end
    end
    return false
  end

  def forty?(trump_suit)
    @deck.group_by { |card| card.suit }.each do |suit, group|
      if group.include?(Card.new(:king, suit)) &&
        group.include?(Card.new(:queen, suit)) && suit == trump_suit
        return true
      end
    end
    return false
  end
end

class SixtySixDeck < Deck
  HAND_SIZE = 6

  def deal
    PlayerSixtySixDeck.new(SixtySixDeck.new(@deck.slice!(0...HAND_SIZE)))
  end

  private

  def ranks
    [9, :jack, :queen, :king, 10, :ace]
  end
end

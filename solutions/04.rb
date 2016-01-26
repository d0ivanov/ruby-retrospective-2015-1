class Card
  attr_reader :rank, :suit

  def initialize(rank, suit)
    @rank, @suit = rank, suit
  end

  def ==(other)
    [@rank, @suit] == [other.rank, other.suit]
  end

  def to_s
    "#{@rank.to_s.capitalize} of #{@suit.to_s.capitalize}"
  end
end

class Deck
  include Enumerable

  def initialize(ranks, suits, cards = nil)
    @ranks, @suits = ranks, suits

    if cards == nil
      @deck = ranks.product(suits).map { |rank, suit| Card.new(rank, suit) }
    else
      @deck = cards.dup
    end
  end

  def each(&block)
    @deck.each(&block)
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
    @deck.shuffle!
  end

  def to_s
    @deck.map(&:to_s).join("\n")
  end

  def deal
    PlayerDeck.new(Deck.new(@deck.sample(rand(srand) % size)))
  end

  def sort
    @deck.sort! do |a, b|
      if @suits.index(a.suit) == @suits.index(b.suit)
        @ranks.index(a.rank) <=> @ranks.index(b.rank)
      else
        @suits.index(a.suit) <=> @suits.index(b.suit)
      end
    end
    @deck.reverse!
  end

  class Hand
    def initialize(deck)
      @deck = deck
    end

    def size
      return @deck.size
    end
  end
end

class WarDeck < Deck
  SUITS = [:clubs, :diamonds, :hearts, :spades]
  RANKS = [2, 3, 4, 5, 6, 7, 8, 9, 10, :jack, :queen, :king, :ace]

  HAND_SIZE = 26

  def initialize(cards = nil)
    super(RANKS, SUITS, cards)
  end

  def deal
    WarHand.new(WarDeck.new(@deck.slice!(0...HAND_SIZE)))
  end

  class WarHand < Hand
    def play_card
      @deck.draw_top_card
    end

    def allow_face_up?
      @deck.size <= 3
    end
  end
end

class BeloteDeck < Deck
  SUITS = [:clubs, :diamonds, :hearts, :spades]
  RANKS = [7, 8, 9, :jack, :queen, :king, 10, :ace]
  HAND_SIZE = 8

  def initialize(cards = nil)
    super(RANKS, SUITS, cards)
  end

  def deal
    BeloteHand.new(BeloteDeck.new(@deck.slice!(0...HAND_SIZE)))
  end

  class BeloteHand < Hand
    def highest_of_suit(suit)
      @deck.sort.select { |card| card.suit == suit }.first
    end

    def belote?
      SUITS.any? do |suit|
        has_queen = @deck.include?(Card.new(:queen, suit))
        has_king = @deck.include?(Card.new(:king, suit))

        has_queen && has_king
      end
    end

    def tierce?
      consecutive_cards?(3)
    end

    def quarte?
      consecutive_cards?(4)
    end

    def quint?
      consecutive_cards?(5)
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

    def consecutive_cards?(card_count)
      sorted_cards = @deck.sort_by {|card| RANKS.find_index(card.rank)}

      SUITS.any? do |suit|
        cards_of_suit = sorted_cards.select { |card| card.suit == suit }

        next false if cards_of_suit.size < card_count

        cards_of_suit.each_cons(card_count).any? do |cards|
          consecutive_ranks?(cards)
        end
      end
    end

    def consecutive_ranks?(cards)
      cards.each_cons(2).all? do |card_a, card_b|
        RANKS.find_index(card_a.rank) + 1 == RANKS.find_index(card_b.rank)
      end
    end
  end
end

class SixtySixDeck < Deck
  SUITS = [:clubs, :diamonds, :hearts, :spades]
  RANKS = [9, :jack, :queen, :king, 10, :ace]
  HAND_SIZE = 6

  def initialize(cards = nil)
    super(RANKS, SUITS, cards)
  end

  def deal
    SixtySixHand.new(SixtySixDeck.new(@deck.slice!(0...HAND_SIZE)))
  end


  class SixtySixHand < Hand
    def twenty?(trump_suit)
      pair_of_queen_and_king?(SUITS - [trump_suit])
    end

    def forty?(trump_suit)
      pair_of_queen_and_king?([trump_suit])
    end

    private

    def pair_of_queen_and_king?(allowed_suits)
      allowed_suits.any? do |suit|
        has_queen = @deck.include?(Card.new(:queen, suit))
        has_king = @deck.include?(Card.new(:king, suit))

        has_queen && has_king
      end
    end
  end
end

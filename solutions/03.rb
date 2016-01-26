class RationalSequence
  include Enumerable

  def initialize(limit)
    @limit = limit
  end

  def each(&block)
    enum_for(:next_rational)
      .lazy
      .take(@limit)
      .each(&block)
  end

  private

  def next_rational
    i = 1
    loop do
      rationals(i) { |rational| yield rational }
      i += 1
    end
  end

  def rationals(slice)
    numerator, denominator = 1, 1

    slice.downto(1) do |n|
      numerator, denominator = slice - (n - 1), n
      if numerator.gcd(denominator) == 1 and slice.odd?
        yield Rational(numerator, denominator)
      elsif numerator.gcd(denominator) == 1
        yield Rational(denominator, numerator)
      end
    end
  end
end

class PrimeSequence
  include Enumerable

  def initialize(limit)
    @limit = limit
  end

  def each(&block)
    enum_for(:primes)
      .lazy
      .take(@limit)
      .each(&block)
  end

  private

  def primes
    prime = 2
    loop do
      yield prime if is_prime?(prime)
      prime += 1
    end
  end

  def is_prime? number
    return false if number <= 1
    Math.sqrt(number).to_i.downto(2).each { |i| return false if number % i == 0 }
    true
  end
end

class FibonacciSequence
  include Enumerable

  def initialize(limit, first: 1, second: 1)
    @limit, @first, @second = limit, first, second
  end

  def each(&block)
    enum_for(:fibonacci)
      .lazy
      .take(@limit)
      .each(&block)
  end

  private

  def fibonacci
    a, b = @first, @second

    yield a
    yield b

    loop do
      yield a + b
      a, b = b, a + b
    end
  end
end

module DrunkenMathematician
  def self.meaningless(n)
    rationals = RationalSequence.new(n).to_a

    group_one, group_two = rationals.partition do |r|
      is_prime?(r.numerator) || is_prime?(r.denominator)
    end

    group_one.reduce(1, :*) / group_two.reduce(1, :*)
  end

  def self.aimless(n)
    primes = PrimeSequence.new(n).to_a
    primes.each_slice(2).to_a.map { |slice| Rational(*slice) }.reduce(:+)
  end

  def self.worthless(n)
    limit = FibonacciSequence.new(n).to_a.last
    sum = 0

    RationalSequence.new(limit ** 2).take_while do |rational|
      sum += rational
      sum <= limit
    end
  end

  private

  def self.is_prime? number
    return false if number <= 1
    Math.sqrt(number).to_i.downto(2).each { |i| return false if number % i == 0 }
    true
  end
end

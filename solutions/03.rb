class RationalSequence
  include Enumerable

  def initialize(limit)
    @limit = limit
    @count = 0
  end

  def each
    slice = 1
    while @count != @limit
      rationals_slice(slice) do |rational|
        yield rational
        @count += 1
      end
      slice += 1
    end
  end

  private

  def rationals_slice(slice)
    slice.downto(1) do |n|
      numerator, denominator = slice - (n - 1), n
      if numerator.gcd(denominator) == 1 and slice.odd?
        yield Rational(numerator, denominator)
      elsif numerator.gcd(denominator) == 1
        yield Rational(denominator, numerator)
      end
      return if @count == @limit
    end
  end
end

class PrimeSequence
  include Enumerable

  def initialize(limit)
    @limit = limit
  end

  def each
    prime_count = 0
    (1..Float::INFINITY).each do |number|
      if is_prime? number
        prime_count += 1
        yield number
      end
      return if prime_count == @limit
    end
  end

  private

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

  def each
    (1..@limit).each {|n| yield fibonacci(n)}
  end

  private

  def fibonacci(n)
    return @first if n == 1
    return @second if n == 2

    fibonacci(n - 1) + fibonacci(n - 2)
  end
end

module DrunkenMathematician
  module_function

  def meaningless(n)
    rationals = RationalSequence.new(n).to_a

    group_one = rationals.select do |rational|
      is_prime? rational.numerator or is_prime? rational.denominator
    end
    group_two = rationals.select do |rational|
      not is_prime? rational.numerator and not is_prime? rational.denominator
    end

    group_one.reduce(1, :*) / group_two.reduce(1, :*)
  end

  def aimless(n)
    primes = PrimeSequence.new(n).to_a
    primes.each_slice(2).to_a.map { |slice| Rational(*slice) }.reduce(0, :+)
  end

  def worthless(n)
    fibonacci_number = FibonacciSequence.new(n).to_a.last
    rationals_slice = []

    RationalSequence.new(Float::INFINITY).each do |rational|
      rationals_slice.push rational
      if rationals_slice.reduce(:+) > fibonacci_number
        return rationals_slice[0...rationals_slice.size - 1]
      end
    end
  end

  def is_prime? number
    return false if number <= 1
    Math.sqrt(number).to_i.downto(2).each { |i| return false if number % i == 0 }
    true
  end
end

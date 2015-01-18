class NumberSet
  include Enumerable

  def initialize(array: [])
    @numbers = array
  end

  def <<(number)
    @numbers << number unless @numbers.include? number
  end

  def size
    @numbers.size
  end

  def empty?
    @numbers.empty?
  end

  def each(&block)
    @numbers.each(&block)
  end

  def [](filter)
    NumberSet.new array: @numbers.select { |number| filter.approve? number }
  end
end

class Filter
  def initialize(&block)
    @condition = block
  end

  def approve?(number)
    @condition.call number
  end

  def &(other_filter)
    Filter.new { |number| approve? number and other_filter.approve? number }
  end

  def |(other_filter)
    Filter.new { |number| approve? number or other_filter.approve? number }
  end
end

class TypeFilter < Filter
  def initialize(number_type)
    case number_type
    when :integer
      super() { |number| number.kind_of? Integer }
    when :complex
      super() { |number| number.kind_of? Complex }
    else
      super() { |number| number.kind_of? Rational or number.kind_of? Float }
    end
  end
end

class SignFilter < Filter
  def initialize(compared_to_zero)
    case compared_to_zero
    when :positive     then super() { |number| number >  0 }
    when :non_positive then super() { |number| number <= 0 }
    when :negative     then super() { |number| number <  0 }
    else super() { |number| number >= 0 }
    end
  end
end

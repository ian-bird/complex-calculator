# frozen_string_literal: true

# a rule contains a left hand term, a lexeme to reduce to,
# and right hand terms, that list the lexemes
# and the order needed to generate the lht
class Rule
  attr_reader :lht, :rhts

  # create a new rule.
  # lht is a non-determinant lexeme symbol
  # rhts is an array of lexeme symbols
  def initialize(lht, rhts)
    raise "Invalid init for Rule: #{lht}, #{rhts}" unless lht.is_a?(Symbol) && rhts.is_a?(Array)

    @lht = lht
    @rhts = rhts
  end

  def to_s
    "< lht #{lht}>, <rhts #{rhts}>"
  end

  def ==(other)
    other.is_a?(Rule) && other.lht == lht && other.rhts == rhts
  end

  # wrapper of ==
  def eql?(other)
    self == other
  end

  def hash
    to_s.hash
  end
end
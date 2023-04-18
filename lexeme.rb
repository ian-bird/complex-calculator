# frozen_string_literal: true

# Lexeme class that terminal and nonterminal inherit from.
# it is an organizational element and has no direct functionality
# but it allows arrays to be checked that they contain only true
# lexemes
class Lexeme
  # default initializer
  def initialize() 
    @parent = nil
  end

  protected

  attr_accessor :parent
end

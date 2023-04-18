# frozen_string_literal: true

require './nonterminal'
require './terminal'

# generates factorio blueprint strings from
# a factorio HDL abstract syntax tree
class CodeGen
  def initialize(transforms)
    raise 'ERROR: input is not an array' unless transforms.is_a? Array
    raise 'ERROR: non-transformation element in input' unless transforms.all? { |element| element.is_a? Transformation }

    @transforms = transforms
  end

  def run(ast)
    to_reduce = find_near_terminal_lexemes(ast)
    output = ''

    # loop until ast is nil
    while ast.is_a? NonTerminal
      raise 'ERROR: no near terminals, cannot reduce' if to_reduce.length.zero?

      restart = false
      # for each lexeme to reduce
      to_reduce.each do |lexeme|
        next if restart

        # for each transform rule
        transforms.each do |transform|
          next if restart
          next unless transform.match? lexeme

          # if reducing the root
          output += transform.output lexeme
          if lexeme == ast
            # set ast to nil so the loop exits
            ast = nil
          else # reducing a node that isnt root
            # do the reduction
            transform.reduce lexeme
            # recalculate the find_near_terms
            to_reduce = find_near_terminal_lexemes ast
          end
          # restart if a rule has been executed
          restart = true
        end
      end
    end
    output
  end

  private

  def find_near_terminal_lexemes(lexeme)
    to_return = []
    if lexeme.children.all? { |child| child.is_a? Terminal }
      to_return << lexeme
    else
      lexeme.children.each do |child|
        to_return += find_near_terminal_lexemes(child) if child.is_a? NonTerminal
      end
    end
    to_return
  end

  attr_reader :transforms
end

# frozen_string_literal: true

require './terminal'
require './nonterminal'
require './lexeme'
require './rule'

# encodes a tree transformation
# generated and used to reduce
# an AST and generate output code
class Transformation
  # confirm input validity and store
  def initialize(rule, output_rule, reduce_rule)
    raise 'ERROR: invalid type for Transformation.new(rule)' unless rule.is_a? Rule
    raise 'ERROR: invalid type for Transformation.new(output_rule)' unless output_rule.is_a? Proc
    raise 'ERROR: invalid type for Transformation.new(reduce_rule)' unless reduce_rule.is_a? Proc

    @rule = rule
    @output_rule = output_rule
    @reduce_rule = reduce_rule
  end

  # does the passed lexeme match this tree transformation?
  def match?(lexeme)
    lexeme.children.collect(&:type) == rule.rhts and lexeme.type == rule.lht
  end

  # get the output that will go to a file for this transformation
  def output(lexeme)
    raise 'ERROR: cannot get string unless trees match' unless match? lexeme

    output_string = output_rule.call lexeme.children

    raise 'ERROR: output rule block does not return string' unless output_string.is_a? String

    output_string
  end

  # replaces the matched lexeme tree with the output of the reduce rule
  def reduce(lexeme)
    raise 'ERROR: cannot get string unless trees match' unless match? lexeme

    reduce_return = reduce_rule.call lexeme.children
    if reduce_return.is_a? Array
      new_lexeme = reduce_return[0]
      new_lexeme.context = reduce_return[1]
    else
      new_lexeme = reduce_return
    end

    raise 'ERROR: reduce rule does not return a terminal' unless new_lexeme.is_a? Terminal

    lexeme.replace_with new_lexeme
  end

  private

  attr_reader :rule, :output_rule, :reduce_rule
end

# frozen_string_literal: true

require './lexeme'
require './rule'

# a NonTerminal is a Lexeme generated by the parser.
# It represents an inner node or the root of the abstract
# syntax tree. Rules checking is handled entirely by the parser.
class NonTerminal < Lexeme
  attr_reader :rule, :type, :children

  # rule is the reduction rule that has been applied.
  # It's used by the parser when making further reductions.
  # children is an ordered array that shows the break down
  # of the non-terminal.
  # elements of children must be Lexemes.
  def initialize(rule, children)
    super()
    @parent = nil
    @rule = rule
    @type = rule.lht

    unless children.all? { |child| child.is_a? Lexeme }
      raise ArgumentError.new, 'non-lexeme items passed to NonTerminal'
    end

    @children = children.clone
    @children.each { |child| child.parent = self }
  end

  # replaces the child lexeme with the new child
  # updates parent for the new child
  # updates rule as well
  def replace_child(child, new_child)
    # break parent link
    child.parent = nil
    # get the index
    child_index = children.find_index child
    # replace the child
    children[child_index] = new_child
    # set parent value
    new_child.parent = self
    # get the new rhts
    new_rhts = children.collect(&:type)
    # update rule
    new_rule = Rule.new(rule.lht, new_rhts)
    rule = new_rule
    nil
  end

  # replace self
  def replace_with(new_child)
    parent.replace_child(self, new_child) unless parent == nil
  end

  def to_s
    "< rule: #{rule}, type: '#{type}', children: #{children} >"
  end

  def parent
    super()
  end

  def parent=(other)
    super(other)
  end

  private

  attr_writer :rule, :children
end
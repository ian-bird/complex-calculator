# frozen_string_literal: true

require './lexer/lex'
require './parser/parse'
require './generator/gendefs'
require './generator/codegen'

BUILD_BBNF = false

if BUILD_BBNF
  # convert bnf style input to internally defined
  # basic backhaus-naur form
  lex_defs = File.read 'ebnf/lexdefs.txt'
  lexer = Lex.new lex_defs
  lexemes = lexer.run(File.read('calc_interm/parsedefs.bnf'))

  parse_defs = File.read 'ebnf/parsedefs.txt'
  parser = Parse.new parse_defs
  ast = parser.run lexemes

  generator = CodeGen.new GenDefs.bbnf
  File.write 'calc_interm/parsedefs.txt', generator.run(ast)

  parse_defs = File.read 'calc_interm/parsedefs.txt'
  parser = Parse.new parse_defs

  File.open('calc_interm/parser.rob', 'wb') { |io| Marshal.dump(parser, io) }
end
puts 'enter your problem:'
input = gets.chomp

lex_defs = File.read 'calc_interm/lexdefs.txt'
lexer = Lex.new lex_defs
lexemes = lexer.run(input)

parser = File.open('calc_interm/parser.rob', 'rb') { |io| Marshal.load(io) }
ast = parser.run lexemes

generator = CodeGen.new GenDefs.calc_interm
puts generator.run(ast)

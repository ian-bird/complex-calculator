# frozen_string_literal: true

require './terminal'

# lexical analyzer.
# pulls lex rules from lexdefs.txt
class Lex
  # set up the rules hash. No checking is done to make
  # sure the file is formatted properly.
  def initialize(file)
    @rules_hash = {}
    lines = file.split("\n")
    lines.each do |line|
      # if the line has an assignment but an invalid lValue
      unless !line.match?(/=/) || line.match?(/\w+(?==)/)
        # must have valid lValue
        raise "ERROR: cannot parse '#{line}': unrecognized lValue"
      end

      if line.match?(/\(\?<=/)
        puts 'each terminal consumes all the string in front of it, and'
        puts 'each terminal tries to match from the start of the line'
        puts 'this functionality plus lookahead allows for effective'
        puts 'look behind.'
        raise "ERROR: cannot parse '#{line}': look behind unsupported"
      end

      pattern = Regexp.new "^#{line.match(%r{(?<==/).*(?=/\w*$)})}"
      @rules_hash[line.match(/\w+(?==)/).to_s] = pattern
    end
  end

  # run the lexer.
  # This takes a string containing the contents of the
  # file to parse and returns an array of LexTokens.
  #
  # Implementation: try all rules against the start of the string.
  # if no rule matches, generate and error and abort.
  # if at least one matches, select the highest rule, create the token and add to to_return
  # use more specific regexes higher up and generalized ones lower so that the
  # general rules don't catch everything.
  def run(file)
    file_copy = file.clone.gsub('\n','').split("\n").join('\n')
    number_of_lines_in_file = file_copy.split('\n', -1).count
    to_return = []
    has_error = false
    # reduce down the string until emtpy
    while file_copy != ''
      file_copy = file_copy[2..] while file_copy.match?(/^\\n/)

      # rules that match the input
      matches = []
      # check each rule, add if match
      @rules_hash.each_key do |key|
        pattern = @rules_hash[key]

        matches << { string: file_copy.match(pattern).to_s, key: key } if file_copy.match? pattern
      end

      # if invalid match
      if matches.empty?
        has_error = true

        lines_remaining = file_copy.split('\n', -1).count
        line_num = number_of_lines_in_file - lines_remaining + 1
        puts "lexical error on line #{line_num}, starting at #{file_copy.chars.first}"
        # try to recover
        matches = []
        while matches.empty? && !file_copy.empty?
          file_copy = file_copy[1..]
          @rules_hash.each_key do |key|
            pattern = @rules_hash[key]

            matches << { string: file_copy.match(pattern).to_s, key: key } if file_copy.match? pattern
          end
        end
      end

      match_length = matches[0][:string].length
      file_copy = file_copy[match_length..] # chop the match off the front

      # unless its an ignore statement
      unless matches.first[:key] == '__IGNORE__'
        # add the lexeme to the stream
        lines_remaining = file_copy.split('\n', -1).count
        to_return << Terminal.new(matches.first[:key], matches.first[:string], number_of_lines_in_file - lines_remaining + 1)
      end
    end

    raise "lexical error" if has_error
    to_return << Terminal.new('$', '')
    to_return
  end
end

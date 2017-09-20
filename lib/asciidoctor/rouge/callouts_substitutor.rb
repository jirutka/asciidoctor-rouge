# frozen_string_literal: true
require 'English'
require 'asciidoctor'
require 'asciidoctor/inline'
require 'asciidoctor/substitutors'
require 'asciidoctor/rouge/version'

module Asciidoctor::Rouge
  # A substitutor for processing callouts inside a source listing block.
  class CalloutsSubstitutor

    # @return [Hash<Integer, Array<Integer>>]
    attr_reader :callouts

    # @param node [Asciidoctor::AbstractNode]
    # @return [CalloutsSubstitutor] a callouts substitutor for the given _node_.
    def self.create(node)
      new(node)
    end

    # Extracts and stashes callout markers from the given _text_ for
    # reinsertion after processing.
    #
    # This should be used prior passing the source to a code highlighter.
    #
    # @param text [#each_line] source of the listing block.
    # @return [String] a copy of the _text_ with callout marks removed.
    def extract(text)
      escape_char = ::Asciidoctor::Substitutors::RS
      @callouts.clear

      text.each_line.with_index(1).map { |line, ln|
        line.gsub(@callout_rx) do
          match = $LAST_MATCH_INFO
          if match[1] == escape_char
            # We have to use sub since we aren't sure it's the first char.
            match[0].sub(escape_char, '')
          else
            (@callouts[ln] ||= []) << match[3].to_i
            nil
          end
        end
      }.join
    end

    # Converts and restores the extracted callouts for the given _text_.
    #
    # @param text [#each_line]
    # @return [String] a copy of the _text_ with inserted callouts.
    def restore(text)
      return text if @callouts.empty?

      text.each_line.with_index(1).map { |line, ln|
        if (conums = @callouts.delete(ln))
          line.chomp + conums.map { |num| convert_callout(num) }.join(' ') + "\n"
        else
          line
        end
      }.join
    end

    protected

    # (see .create)
    def initialize(node)
      @node = node
      @callouts = {}

      @callout_rx = if node.attr? 'line-comment'
        comment_rx = ::Regexp.escape(node.attr('line-comment'))
        /(?:#{comment_rx} )?#{::Asciidoctor::CalloutExtractRxt}/
      else
        ::Asciidoctor::CalloutExtractRx
      end
    end

    # @param number [Integer] callout number.
    # @return [String] an HTML markup of callout with the given _number_.
    def convert_callout(number)
      ::Asciidoctor::Inline.new(@node, :callout, number, id: next_callout_id).convert
    end

    # @return [Integer] an unique ID for callout.
    def next_callout_id
      (@doc_callouts ||= @node.document.callouts).read_next_id
    end
  end
end

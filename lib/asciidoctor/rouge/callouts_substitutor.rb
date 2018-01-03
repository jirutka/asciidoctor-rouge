# frozen_string_literal: true
require 'English'
require 'asciidoctor'
require 'asciidoctor/inline'
require 'asciidoctor/substitutors'
require 'asciidoctor/rouge/constants'

module Asciidoctor::Rouge
  # A substitutor for processing callouts inside a source listing block.
  class CalloutsSubstitutor

    # @return [Hash<Integer, Array<Integer>>]
    attr_reader :callouts

    # @param node [Asciidoctor::AbstractNode]
    # @return [CalloutsSubstitutor] a callouts substitutor for the given *node*.
    def self.create(node)
      new(node)
    end

    # Extracts and stashes callout markers from the given *text* for
    # reinsertion after processing.
    #
    # This should be used prior passing the source to a code highlighter.
    #
    # @param text [#each_line] source of the listing block.
    # @return [String] a copy of the *text* with callout marks removed.
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

    # Converts the extracted callout markers for the specified line.
    #
    # @param line_num [Integer] the line number (1-based).
    # @return [String] converted callout markers for the _line_num_,
    #   or an empty string if there are no callouts for that line.
    def convert_line(line_num)
      return '' unless @callouts.key? line_num

      @callouts[line_num]
        .map { |num| convert_callout(num) }
        .join(' ')
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
    # @return [String] an HTML markup of a callout marker with the given *number*.
    def convert_callout(number)
      ::Asciidoctor::Inline.new(@node, :callout, number, id: next_callout_id).convert
    end

    # @return [Integer] an unique ID for callout.
    def next_callout_id
      (@doc_callouts ||= @node.document.callouts).read_next_id
    end
  end
end

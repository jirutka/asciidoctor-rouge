# frozen_string_literal: true
require 'asciidoctor/rouge/version'
require 'rouge'

module Asciidoctor::Rouge
  # An HTML Rouge formatter with support for lines ID and highlighted lines.
  class HtmlFormatter < ::Rouge::Formatter

    tag 'asciidoctor_html'

    # @param parent [Rouge::Formatter] the parent formatter; it must respond
    #   to method +span(token, value)+. Defaults to +Rouge::Formatters::HTML+.
    #
    # @param highlight_lines [Array<Integer>] a list of line numbers
    #   (1-based) to be highlighted (i.e. added _highlight_class_ to a line
    #   wrapper element). Defaults to empty array.
    #
    # @param highlight_class [String] CSS class to use on a line wrapper
    #   element for highlighted lines (see above). Defaults to "highlighted".
    #
    # @param line_id [String] format string specifying +id+ for each line.
    #   Defaults to "L%i".
    #
    # @param line_class [String] CSS class to use on a line wrapper element.
    #   Defaults to "line".
    #
    def initialize(parent: ::Rouge::Formatters::HTML.new,
                   highlight_lines: [],
                   highlight_class: 'highlighted',
                   line_id: 'L%i',
                   line_class: 'line', **)
      @parent = parent
      @highlight_lines = highlight_lines
      @highlight_class = highlight_class
      @line_id = line_id
      @line_class = line_class
    end

    def stream(tokens)
      lno = 1
      token_lines(tokens) do |line|
        yield "\n" if lno > 1
        yield line_open(lno)

        line.each do |token, value|
          yield @parent.span(token, value)
        end

        yield line_close

        lno += 1
      end
    end

    protected

    def line_open(lno)
      classes = [
        @line_class,
        (@highlight_class if highlighted? lno),
      ].compact.join(' ')

      %(<span id=#{sprintf(@line_id, lno).inspect} class=#{classes.inspect}>)
    end

    def line_close
      %(</span>)
    end

    def highlighted?(lno)
      @highlight_lines.include?(lno)
    end
  end
end

# frozen_string_literal: true
require 'asciidoctor/rouge/constants'
require 'rouge'

module Asciidoctor::Rouge
  # An HTML Rouge formatter for Asciidoctor with support for callouts and
  # highlighted lines.
  class HtmlFormatter < ::Rouge::Formatter

    tag 'asciidoctor_html'

    # @param callout_markers [#[], nil] callout markers indexed by
    #   line numbers to be inserted between the line's content and the line's
    #   closing tag.
    #
    # @param highlighted_class [String] CSS class to use on a line wrapper
    #   element for highlighted lines (see above). Defaults to "highlighted".
    #
    # @param highlighted_lines [Array<Integer>] a list of line numbers
    #   (1-based) to be highlighted (i.e. added _highlighted_class_ to a line
    #   wrapper element). Defaults to empty array.
    #
    # @param inline_theme [String, Rouge::Theme, Class<Rouge::Theme>, nil]
    #   the theme to use for inline styles, or `nil` to not set inline styles
    #   (i.e. use classes). This is ignored if *inner* is not `nil`.
    #
    # @param line_class [String, nil] CSS class to set on a line wrapper
    #   element, or `nil` to not set a class. Defaults to "line".
    #
    # @param line_id [String, nil] format string specifying `id` for each line,
    #   or `nil` to omit `id`. Defaults to "L%i".
    #
    # @param inner [Rouge::Formatter::HTML, #span, nil] the inner HTML
    #   formatter to delegate formatting of tokens to, or `nil` to get
    #   `html` or `html_inline` formatter from the `Rouge::Formatter`'s
    #   registry.
    #
    def initialize(callout_markers: nil,
                   highlighted_class: 'highlighted',
                   highlighted_lines: [],
                   inline_theme: nil,
                   line_class: 'line',
                   line_id: 'L%i',
                   inner: nil, **)

      inner ||= if inline_theme
        ::Rouge::Formatter.find('html_inline').new(inline_theme)
      else
        ::Rouge::Formatter.find('html').new
      end

      @callout_markers = callout_markers || {}
      @inner = inner
      @highlighted_lines = highlighted_lines || []
      @highlighted_class = highlighted_class
      @line_id = line_id
      @line_class = line_class
    end

    def stream(tokens, &block)
      token_lines(tokens).with_index(1) do |line_tokens, lno|
        stream_lines(line_tokens, lno, &block)
      end
    end

    # Formats tokens on the specified line into HTML.
    #
    # @param tokens [Array<Rouge::Token>] tokens on the line.
    # @param line_nums [Integer] the line number (1-based).
    # @yield [String] gives formatted content.
    def stream_lines(tokens, line_num)
      yield line_start(line_num)

      tokens.each do |token, value|
        yield @inner.span(token, value)
      end

      yield line_end(line_num)
    end

    protected

    def line_start(line_num)
      classes = [
        @line_class,
        (@highlighted_class if highlighted? line_num),
      ].compact.join(' ')

      [
        ("\n" if line_num > 1),
        '<span',
        (" id=#{sprintf(@line_id, line_num).inspect}" if @line_id),
        (" class=#{classes.inspect}" if !classes.empty?),
        '>',
      ].compact.join
    end

    def line_end(line_num)
      %(#{@callout_markers[line_num]}</span>)
    end

    def highlighted?(line_num)
      @highlighted_lines.include?(line_num)
    end
  end
end

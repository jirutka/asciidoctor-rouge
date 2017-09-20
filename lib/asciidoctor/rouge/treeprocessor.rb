# frozen_string_literal: true
require 'asciidoctor/rouge/version'
require 'asciidoctor/rouge/callouts_substitutor'
require 'asciidoctor/rouge/html_formatter'
require 'asciidoctor/rouge/passthroughs_substitutor'
require 'asciidoctor/extensions'
require 'rouge'

module Asciidoctor::Rouge
  # An Asciidoctor extension that highlights source listings using Rouge.
  class Treeprocessor < ::Asciidoctor::Extensions::Treeprocessor

    # @param formatter [Class<Rouge::Formatter>] the Rouge formatter to use for
    #   formatting a token stream from a Rouge lexer. It must respond to method
    #   +format+ accepting a token stream and (optionally) a hash of options,
    #   producing +String+. Defaults to {HtmlFormatter}.
    #
    # @param formatter_opts [Hash] options to pass to the _formatter_.
    #   It's used only if _formatter's_ +format+ method has arity > 1.
    #   Defaults to empty hash.
    #
    # @param callouts_sub [#create] the callouts substitutor class to use for
    #   processing callouts. Defaults to {CalloutsSubstitutor}.
    #
    # @param passthroughs_sub [#create] the passthroughs substitutor class to
    #   use for processing passthroughs.
    #   Defaults to {PassthroughsSubstitutor}.
    #
    def initialize(formatter: HtmlFormatter,
                   formatter_opts: {},
                   callouts_sub: CalloutsSubstitutor,
                   passthroughs_sub: PassthroughsSubstitutor, **)
      super

      @formatter = formatter
      @formatter_opts = formatter_opts
      @callouts_sub = callouts_sub
      @passthroughs_sub = passthroughs_sub
    end

    # @param document [Asciidoctor::Document] the document to process.
    def process(document)
      return unless document.attr? 'source-highlighter', 'rouge'

      document.find_by(context: :listing, style: 'source') do |block|
        process_listing(block)
      end
    end

    protected

    # @param block [Asciidoctor::Block] the listing block to highlight.
    def process_listing(block)
      source = block.source  # String
      subs = block.subs  # Array<Symbol>

      # Don't escape special characters, Rouge will take care of it.
      subs.delete(:specialcharacters)

      if subs.delete(:macros)
        passthroughs = @passthroughs_sub.create(block)
        source = passthroughs.extract(source)
      end

      if subs.delete(:callouts)
        callouts = @callouts_sub.create(block)
        source = callouts.extract(source)
      end

      source = block.apply_subs(source, subs)
      subs.clear

      lang = block.attr('language', 'plaintext', false)
      lexer = find_lexer(lang)
      block.set_attr('language', lexer.tag)

      if block.attr?('highlight', nil, false)
        highlight_lines = block.resolve_highlight_lines(block.attr('highlight', '', false))
      end

      result = highlight(lexer, source, highlight_lines)
      result = callouts.restore(result) if callouts
      result = passthroughs.restore(result) if passthroughs

      block.lines.replace(result.split("\n"))
    end

    # @param language [String]
    # @return [Rouge::Lexer] a lexer for the specified _language_.
    def find_lexer(language)
      (::Rouge::Lexer.find(language) || ::Rouge::Lexers::PlainText).new
    end

    # @param lexer [Rouge::Lexer] the lexer to use.
    # @param source [String] the code to highlight.
    # @param highlight_lines [Array<Integer>] a list of line numbers (1-based)
    #   to be highlighted.
    # @return [String] a highlighted and formatted _source_.
    def highlight(lexer, source, highlight_lines = [])
      tokens = lexer.lex(source)

      if @formatter.method(:format).arity.abs > 1
        opts = @formatter_opts.merge(highlight_lines: highlight_lines || [])
        @formatter.format(tokens, opts)
      else
        @formatter.format(tokens)
      end
    end
  end
end

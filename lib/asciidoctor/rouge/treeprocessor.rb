# frozen_string_literal: true
require 'asciidoctor/rouge/constants'
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

      # Table cells may contain listing, but Document#find_by does not search
      # inside table, so we must handle it specially.
      document.find_by(context: :table) do |table|
        table.rows.body.each do |row|
          row.each do |cell|
            if (inner = cell.inner_document)
              inner.find_by(context: :listing, style: 'source') do |block|
                process_listing(block)
              end
            end
          end
        end
      end
    end

    protected

    # @param block [Asciidoctor::Block] the listing block to highlight.
    def process_listing(block)
      document = block.document
      source = block.source  # String
      subs = block.subs  # Array<Symbol>
      opts = {}

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

      if document.attr?('rouge-css', 'style')
        opts[:inline_theme] = document.attr('rouge-theme', DEFAULT_THEME)
      end

      if block.attr?('highlight', nil, false)
        highlight = block.attr('highlight', '', false)
        opts[:highlighted_lines] = block.resolve_highlight_lines(highlight)
      end

      opts[:callout_markers] = callouts.method(:convert_line) if callouts

      result = highlight(source, lexer, opts)
      result = passthroughs.restore(result) if passthroughs

      block.lines.replace(result.split("\n"))
    end

    # @param language [String]
    # @return [Rouge::Lexer] a lexer for the specified _language_.
    def find_lexer(language)
      (::Rouge::Lexer.find(language) || ::Rouge::Lexers::PlainText).new
    end

    # @param source [String] the code to highlight.
    # @param lexer [Rouge::Lexer] the lexer to use.
    # @param opts [Hash] extra options for the formatter; it will be merged
    #   with the +formatter_opts+ (see {#initialize}).
    # @return [String] a highlighted and formatted _source_.
    def highlight(source, lexer, opts = {})
      tokens = lexer.lex(source)

      if @formatter.method(:format).arity.abs > 1
        @formatter.format(tokens, @formatter_opts.merge(opts))
      else
        @formatter.format(tokens)
      end
    end
  end
end

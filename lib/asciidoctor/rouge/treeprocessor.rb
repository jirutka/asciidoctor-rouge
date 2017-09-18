# frozen_string_literal: true
require 'asciidoctor/rouge/version'
require 'asciidoctor/rouge/callouts_substitutor'
require 'asciidoctor/extensions'
require 'rouge'

module Asciidoctor::Rouge
  # An Asciidoctor extension that highlights source listings using Rouge.
  class Treeprocessor < ::Asciidoctor::Extensions::Treeprocessor

    # @param formatter [Rouge::Formatter]
    # @param callouts_sub [#create] the callouts substitutor class to use for
    #   processing callouts. Defaults to {CalloutsSubstitutor}.
    def initialize(formatter: ::Rouge::Formatters::HTML,
                   callouts_sub: CalloutsSubstitutor, **)
      super

      @formatter = formatter
      @callouts_sub = callouts_sub
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

      if subs.delete(:callouts)
        callouts = @callouts_sub.create(block)
        source = callouts.extract(source)
      end

      source = block.apply_subs(source, subs)
      subs.clear

      lang = block.attr('language', 'plaintext', false)
      lexer = find_lexer(lang)
      block.set_attr('language', lexer.tag)

      result = highlight(lexer, source)
      result = callouts.restore(result) if callouts

      block.lines.replace(result.split("\n"))
    end

    # @param language [String]
    # @return [Rouge::Lexer] a lexer for the specified _language_.
    def find_lexer(language)
      (::Rouge::Lexer.find(language) || ::Rouge::Lexers::PlainText).new
    end

    # @param lexer [Rouge::Lexer] the lexer to use.
    # @param source [String] the code to highlight.
    # @return [String] a highlighted and formatted _source_.
    def highlight(lexer, source)
      @formatter.format(lexer.lex(source))
    end
  end
end

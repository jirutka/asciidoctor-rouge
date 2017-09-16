# frozen_string_literal: true
require 'asciidoctor/rouge/version'
require 'asciidoctor/extensions'
require 'rouge'

module Asciidoctor::Rouge
  # An Asciidoctor extension that highlights source listings using Rouge.
  class Treeprocessor < ::Asciidoctor::Extensions::Treeprocessor

    # @param formatter [Rogue::Formatter]
    def initialize(formatter: Rouge::Formatters::HTML)
      super
      @formatter = formatter
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
      # Don't escape special characters, Rouge takes care of it.
      block.subs.delete(:specialcharacters)

      # Eagry apply substitutions.
      source = block.apply_subs(block.source, block.subs)
      block.subs.clear

      lang = block.attr('language', 'plaintext', false)
      lexer = find_lexer(lang)
      block.set_attr('language', lexer.tag)

      result = highlight(lexer, source)
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

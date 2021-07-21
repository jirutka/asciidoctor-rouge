# frozen_string_literal: true
require 'asciidoctor/rouge/constants'
require 'asciidoctor'
require 'asciidoctor/extensions'
require 'rouge'

module Asciidoctor::Rouge
  # A docinfo processor that embeds CSS for Rouge into the document's header.
  class DocinfoProcessor < ::Asciidoctor::Extensions::DocinfoProcessor

    # @param document [Asciidoctor::Document] the document to process.
    # @return [String, nil]
    def process(document)
      return unless document.attr?('source-highlighter', 'rouge')
      style = document.attr('rouge-css', 'class')

      if (style == 'class')
        if (theme = ::Rouge::Theme.find(document.attr('rouge-theme', DEFAULT_THEME)))
          css = theme.render(scope: '.highlight')
          ['<style>', css, '</style>'].join("\n")
        end
      elsif (style == 'external')
        if (theme = document.attr('rouge-theme'))
          ['<link rel="stylesheet" href="', theme, '">'].join("")
        end
      else
        return
      end
    end
  end
end

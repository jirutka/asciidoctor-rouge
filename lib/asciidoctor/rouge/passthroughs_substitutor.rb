# frozen_string_literal: true
require 'asciidoctor/substitutors'
require 'asciidoctor/rouge/version'

module Asciidoctor::Rouge
  # A substitutor for processing passthroughs inside listing blocks.
  # It's basically just a facade for Asciidoctor's internal methods.
  class PassthroughsSubstitutor

    PASS_START_MARK = ::Asciidoctor::Substitutors::PASS_START
    PASS_END_MARK = ::Asciidoctor::Substitutors::PASS_END
    PASS_SLOT_RX = ::Asciidoctor::Substitutors::HighlightedPassSlotRx

    # @param node [Asciidoctor::AbstractNode]
    # @return [PassthroughsSubstitutor] a passthroughs substitutor for
    #   the given _node_.
    def self.create(node)
      new(node)
    end

    # Extracts passthrough regions from the given text for reinsertion
    # after processing.
    #
    # @param text [String] the source of the node.
    # @return [String] a copy of the _text_ with passthrough regions
    #   substituted with placeholders.
    def extract(text)
      @node.extract_passthroughs(text)
    end

    # Restores the extracted passthroughs by reinserting them into the
    # placeholder positions.
    #
    # @param text [String] the text into which to restore the passthroughs.
    # @return [String] a copy of the _text_ with restored passthroughs.
    def restore(text)
      return text if @node.passthroughs.empty?

      # Fix passthrough placeholders that got caught up in syntax highlighting.
      text = text.gsub(PASS_SLOT_RX, "#{PASS_START_MARK}\\1#{PASS_END_MARK}")

      # Restore converted passthroughs.
      @node.restore_passthroughs(text)
    end

    protected

    # (see .create)
    def initialize(node)
      @node = node
    end
  end
end

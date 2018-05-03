# frozen_string_literal: true
require 'asciidoctor'
require 'asciidoctor/extensions'
require 'asciidoctor/rouge/constants'
require 'asciidoctor/rouge/docinfo_processor'
require 'asciidoctor/rouge/treeprocessor'

Asciidoctor::Extensions.register do
  treeprocessor Asciidoctor::Rouge::Treeprocessor
  docinfo_processor Asciidoctor::Rouge::DocinfoProcessor
end

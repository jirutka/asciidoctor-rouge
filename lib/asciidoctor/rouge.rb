# frozen_string_literal: true
require 'asciidoctor/extensions'
require 'asciidoctor/rouge/version'
require 'asciidoctor/rouge/treeprocessor'

Asciidoctor::Extensions.register do
  treeprocessor Asciidoctor::Rouge::Treeprocessor
end

# frozen_string_literal: true
require 'asciidoctor'
require 'asciidoctor/extensions'
require 'asciidoctor/rouge/constants'
require 'asciidoctor/rouge/docinfo_processor'
require 'asciidoctor/rouge/treeprocessor'

Asciidoctor::Extensions.register do
  opts = {}
  # Allow the user to override the following attributes for the whole document
  # on the comamnd line (e.g. '-a rouge-highlighted-class=my-highlight')
  highlighted_class = document.attr('rouge-highlighted-class')
  opts[:highlighted_class] = highlighted_class if highlighted_class
  line_class = document.attr('rouge-line-class')
  opts[:line_class] = line_class if line_class
  # A single line ID pattern for the whole document doesn't make much sense
  # because it will most probably produce non-unige IDs. So reset to 'nil'
  # by default (i.e. if 'rouge-line-id' isn't given on the command line)
  opts[:line_id] = document.attr('rouge-line-id')
  tree_processor(Asciidoctor::Rouge::Treeprocessor, formatter_opts: opts)
  docinfo_processor Asciidoctor::Rouge::DocinfoProcessor
end

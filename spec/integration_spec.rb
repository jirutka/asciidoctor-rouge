require_relative 'spec_helper'

require 'asciidoctor-rouge'
require 'asciidoctor'
require 'corefines'

using Corefines::String::unindent

module Asciidoctor::Rouge
  describe 'Intengration Tests' do

    class << self; alias_method :test, :it; end

    before do
      @attributes = { 'source-highlighter' => 'rouge' }
    end

    test 'Source block when source-highlighter is not rouge' do
      attributes 'source-highlighter' => 'html-pipeline'
      given <<-ADOC.unindent
        :source-highlighter: html-pipeline

        [source, ruby]
        puts 'Hello, world!'
      ADOC
      expected <<-HTML.unindent
        puts 'Hello, world!'
      HTML
    end

    test 'Source block without language' do
      given <<-ADOC.unindent
        [source]
        puts 'Hello, world!'
      ADOC
      expected <<-HTML.unindent
        puts 'Hello, world!'
      HTML
    end

    test 'Source block with language' do
      given <<-ADOC.unindent
        [source, ruby]
        puts 'Hello, world!'
      ADOC
      expected <<-HTML.unindent
        <span class="nb">puts</span> <span class="s1">'Hello, world!'</span>
      HTML
    end

    test 'Source block with attributes substitution enabled' do
      given <<-ADOC.unindent
        :message: Hello, \#{subject}!

        [source, ruby, subs="+attributes"]
        puts "{message}"
      ADOC
      expected <<-HTML
        <span class="nb">puts</span> <span class="s2">"Hello, </span><span class="si">\#{</span><span class="n">subject</span><span class="si">}</span><span class="s2">!"</span>
      HTML
    end

    test 'Source block with callouts' do
      given <<-ADOC.unindent
        [source, ruby]
        ----
        require 'asciidoctor'  # <1>

        puts 'Hello, world!'   # <2> <3>
        puts 'How are you?'
        ----
      ADOC
      expected <<-HTML.unindent
        <span class="nb">require</span> <span class="s1">'asciidoctor'</span>  <b class="conum">(1)</b>

        <span class="nb">puts</span> <span class="s1">'Hello, world!'</span>    <b class="conum">(2)</b> <b class="conum">(3)</b>
        <span class="nb">puts</span> <span class="s1">'How are you?'</span>
      HTML
    end


    def attributes(hash)
      @attributes.merge!(hash)
    end

    def given(text)
      @actual = Asciidoctor
        .load(text, attributes: @attributes)
        .find_by(context: :listing).first.content
    end

    def expected(text)
      expect( @actual ).to eq text.strip
      @attributes.clear
    end
  end
end

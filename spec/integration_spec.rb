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

    test 'Source block when rouge-css is style' do
      attributes 'rouge-css' => 'style'
      given <<-ADOC.unindent
        [source, ruby]
        puts 'Hello, world!'
      ADOC
      expected <<-HTML.unindent
        <span id="L1" class="line"><span style="color: #0086B3">puts</span> <span style="color: #d14">'Hello, world!'</span></span>
      HTML
    end

    test 'Source block without language' do
      given <<-ADOC.unindent
        [source]
        puts 'Hello, world!'
      ADOC
      expected <<-HTML.unindent
        <span id="L1" class="line">puts 'Hello, world!'</span>
      HTML
    end

    test 'Source block with language' do
      given <<-ADOC.unindent
        [source, ruby]
        puts 'Hello, world!'
      ADOC
      expected <<-HTML.unindent
        <span id="L1" class="line"><span class="nb">puts</span> <span class="s1">'Hello, world!'</span></span>
      HTML
    end

    test 'Source block with attributes substitution enabled' do
      given <<-ADOC.unindent
        :message: Hello, \#{subject}!

        [source, ruby, subs="+attributes"]
        puts "{message}"
      ADOC
      expected <<-HTML
        <span id="L1" class="line"><span class="nb">puts</span> <span class="s2">"Hello, </span><span class="si">\#{</span><span class="n">subject</span><span class="si">}</span><span class="s2">!"</span></span>
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
        <span id="L1" class="line"><span class="nb">require</span> <span class="s1">'asciidoctor'</span>  </span><b class="conum">(1)</b>
        <span id="L2" class="line"></span>
        <span id="L3" class="line"><span class="nb">puts</span> <span class="s1">'Hello, world!'</span>    </span><b class="conum">(2)</b> <b class="conum">(3)</b>
        <span id="L4" class="line"><span class="nb">puts</span> <span class="s1">'How are you?'</span></span>
      HTML
    end

    test 'Source block with passthrough and macros substitution enabled' do
      given <<-ADOC.unindent
        [source, ruby, subs="macros"]
        puts '+++<strong>Oh hai!</strong>+++'
      ADOC
      expected <<-HTML.unindent
        <span id="L1" class="line"><span class="nb">puts</span> <span class="s1">'<strong>Oh hai!</strong>'</span></span>
      HTML
    end

    test 'Source block with highlighted lines' do
      given <<-ADOC.unindent
        [source, ruby, highlight="3,5"]
        ----
        require 'asciidoctor'

        puts "Roses are red,"
        puts "Violets are blue."
        puts "Na'vis too."
        ----
      ADOC
      expected <<-HTML.unindent
        <span id="L1" class="line"><span class="nb">require</span> <span class="s1">'asciidoctor'</span></span>
        <span id="L2" class="line"></span>
        <span id="L3" class="line highlighted"><span class="nb">puts</span> <span class="s2">"Roses are red,"</span></span>
        <span id="L4" class="line"><span class="nb">puts</span> <span class="s2">"Violets are blue."</span></span>
        <span id="L5" class="line highlighted"><span class="nb">puts</span> <span class="s2">"Na'vis too."</span></span>
      HTML
    end

    test 'Source block with callouts and highlighted lines' do
      given <<-ADOC.unindent
        [source, ruby, highlight="3,5"]
        ----
        require 'asciidoctor'  # <1>

        puts "Roses are red,"  # <2>
        puts "Violets are blue."
        puts "Na'vis too."
        ----
      ADOC
      expected <<-HTML.unindent
        <span id="L1" class="line"><span class="nb">require</span> <span class="s1">'asciidoctor'</span>  </span><b class="conum">(1)</b>
        <span id="L2" class="line"></span>
        <span id="L3" class="line highlighted"><span class="nb">puts</span> <span class="s2">"Roses are red,"</span>  </span><b class="conum">(2)</b>
        <span id="L4" class="line"><span class="nb">puts</span> <span class="s2">"Violets are blue."</span></span>
        <span id="L5" class="line highlighted"><span class="nb">puts</span> <span class="s2">"Na'vis too."</span></span>
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

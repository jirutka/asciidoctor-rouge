require_relative '../../spec_helper'

require 'asciidoctor/rouge/callouts_substitutor'
require 'corefines'

module Asciidoctor::Rouge
  describe CalloutsSubstitutor do
    using Corefines::String::unindent

    subject(:substitutor) { described_class.new(block) }
    let(:block) { ::Asciidoctor::Block.new(nil, :listing, {}) }

    let(:text_without_callouts) do
      <<-EOF.unindent
        require 'asciidoctor'

        File.open('example.adoc', 'w') do |f|
          f << 'Hello, world!'
        end
      EOF
    end

    let(:text_with_callouts) do
      <<-EOF.unindent
        require 'asciidoctor'

        File.open('example.adoc', 'w') do |f| %s
          f << 'Hello, world!'
        end                                   %s
      EOF
    end


    describe '.create' do
      it 'returns an instance of CalloutsSubstitutor' do
        expect( described_class.create(block) ).to be_a described_class
      end
    end


    describe '#extract' do

      shared_examples :extract do |callout|
        context %(text with callouts like "#{callout % [1, 2]}") do

          let(:text) do
            text_with_callouts % [callout % callouts[3], callout % callouts[5]]
          end

          let(:callouts) do
            if callout.count('%') == 1
              { 3 => [1], 5 => [3] }
            else
              { 3 => [1, 2], 5 => [3, 4] }
            end
          end

          let!(:result) { substitutor.extract(text) }

          it 'returns text with callouts stripped' do
            expected = text
              .gsub(callout % callouts[3], '')
              .gsub(callout % callouts[5], '')
            expect( result ).to eq expected
          end

          it 'extracts callout numbers' do
            expect( substitutor.callouts ).to eq callouts
          end
        end
      end

      context 'block without attr line-comment' do
        ['', '//', '#', '--', ';;']
          .product(['<%i>', ' <%i>', ' <%i><%i>'])
          .map(&:join).map(&:strip)
          .push('<!--%i-->', '<!--%i--><!--%i-->')
          .each do |callout|

          include_examples :extract, callout
        end
      end

      context 'block with attr line-comment "!!"' do
        before do
          block.set_attr('line-comment', '!!')
        end

        ['!! <%i>', '!! <%i><%i>'].each do |callout|
          include_examples :extract, callout
        end
      end

      context 'text without callouts' do
        let(:text) { text_without_callouts }
        let!(:result) { substitutor.extract(text) }

        it 'returns the given text unchanged' do
          expect( result ).to eq text
        end

        it 'does not extract any callouts' do
          expect( substitutor.callouts ).to be_empty
        end
      end
    end


    describe '#convert_line' do

      context 'no callouts extracted' do
        it 'returns empty string' do
          expect( substitutor.convert_line(1) ).to eq ''
        end
      end

      context 'callouts extracted' do
        let(:callouts) { { 3 => [1], 5 => [3, 4] } }

        before do
          substitutor.callouts.replace(callouts)

          allow( substitutor ).to receive(:convert_callout) do |num|
            "<b>#{num}</b>"
          end
        end

        context 'with line_num of a line with no callouts' do
          it 'returns empty string' do
            expect( substitutor.convert_line(2) ).to eq ''
          end
        end

        context 'with line_num of a line with one callout' do
          it 'returns converted callout marker as a string' do
            expect( substitutor.convert_line(3) ).to eq '<b>1</b>'
          end
        end

        context 'with line_num of a line with more callouts' do
          it 'returns converted callout markers as a string' do
            expect( substitutor.convert_line(5) ).to eq '<b>3</b> <b>4</b>'
          end
        end
      end
    end
  end
end

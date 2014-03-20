require 'paneller/formatters'
require 'colorable'
include Colorable

module Paneller

  describe Formatters::Dzen2 do

    let(:dzen2_class) { Class.new { include Formatters::Dzen2 } }
    let(:dzen2) { dzen2_class.new }

    describe '#colorize' do

      def random_color
        Color.new(Array.new(3) { Random.rand(256) })
      end

      def color_hex(what)
        /(?<#{what}>#[A-F0-9]{6})?/
      end

      let(:color_regex) do
        parts = {}
        [:start, :end].each do |where|
          parts[where] =
            /\^bg\(#{color_hex(:"#{where}_bg")}\)\^fg\(#{color_hex(:"#{where}_fg")}\)/
        end

          /#{parts[:start]}(?<content>.*)#{parts[:end]}/
      end

      it 'returns correct dzen2 color tags for all input types' do
        [:hex, :rgb].each do |input_type|
          [{fg: random_color.send(input_type)},
           {bg: random_color.send(input_type)},
           {fg: random_color.send(input_type), bg: random_color.send(input_type)}].each do |colors|
            expect(dzen2.colorize('test', colors)).to match(/^#{color_regex}$/)
           end
        end

        expect(dzen2.colorize('test', fg: :red, bg: :blue)).to match(/^#{color_regex}$/)
      end

      it 'colorizes what a block passed to it returns' do
        fg_color = random_color.hex

        colorized_string = dzen2.colorize(fg: fg_color) { 'test' }
        expect(colorized_string).to match(/^#{color_regex}$/)

        match = colorized_string.match(/^#{color_regex}$/)

        expect(match[:start_bg]).to be nil
        expect(match[:start_fg]).to eq fg_color

        expect(match[:end_bg]).to be nil
        expect(match[:end_fg]).to be nil

        expect(match[:content]).to eq 'test'
      end

      it 'supports nested colorizing' do
        colors = {
          outer: {bg: random_color.hex, fg: random_color.hex},
          inner: {bg: random_color.hex}
        }

        result = dzen2.colorize(colors[:outer]) do
          content_outer = "outer" 
          content_outer << dzen2.colorize("inner", colors[:inner])
          content_outer + "more for outer"
        end

        expect(result).to match(/^#{color_regex}$/)

        matches = {}
        matches[:outer] = result.match(/^#{color_regex}$/)
        expect(matches[:outer][:content]).to match(/^outer#{color_regex}more for outer$/)

        matches[:inner] = matches[:outer][:content].match(color_regex)
        expect(matches[:inner][:content]).to eq 'inner'

        expected_colors = {}
        expected_colors[:outer] = {:start => colors[:outer],
                                   :end => {bg: nil, fg: nil}}
        expected_colors[:inner] = {:start => colors[:outer].merge(colors[:inner]),
                                   :end => colors[:outer]}

        [:outer, :inner].each do |nesting|
          [:start, :end].each do |where|
            actual_colors = {bg: matches[nesting][:"#{where}_bg"], fg: matches[nesting][:"#{where}_fg"]}
            expect(actual_colors).to eq expected_colors[nesting][where]
          end
        end
      end
    end

    describe '#progress_bar' do

      it 'accepts arguments for percentage and optionally for dimensions' do
        expect { dzen2.progress_bar(50) }.not_to raise_error
        expect { dzen2.progress_bar(50, width: 50, height: 10) }.not_to raise_error
      end

      # what is either :fill or :rest

      def dim_regex(what)
        /(?<#{what}_width>\d+)x(?<#{what}_height>\d+)/
      end

      let(:bar_regex) { /^\^r\(#{dim_regex(:fill)}\)\^ro\(#{dim_regex(:rest)}\)$/ }

      it 'returns correct dzen2 rectangle tags' do
        [25, 100, 500, nil].each do |width|
          [10, nil].each do |height|
            (0..100).each do |percent|
              expect(dzen2.progress_bar(percent, width: width, height: height))
                .to match bar_regex
            end
          end
        end
      end

      it 'returns a rectangle with correct size' do
        [25, 100, 500].each do |width|
          (0..100).each do |i|
            match = dzen2.progress_bar(i, width: width).match(bar_regex)
            total_width = match[:fill_width].to_i + match[:rest_width].to_i

            expect(total_width).to eq width
          end
        end
      end

      it 'raises an argument error if an invalid percentage is given' do
        [-1, 101, nil, 'meh'].each do |percent|
          expect { dzen2.progress_bar(percent) }.to raise_error(ArgumentError)
        end
      end
    end
  end

end

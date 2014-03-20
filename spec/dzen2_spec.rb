require 'paneller/formatters'

module Paneller

  describe Formatters::Dzen2 do

    let(:dzen2_class) { Class.new { include Formatters::Dzen2 } }
    let(:dzen2) { dzen2_class.new }

    describe '#colorize' do

      def random_color
        "##{Random.rand(16777216).to_s(16).upcase.rjust(6, '0')}"
      end

      it 'returns correct dzen2 color tags' do
        [:fg, :bg].each do |what|
          fg_color = random_color
          bg_color = random_color

          expect(dzen2.colorize('test', fg: fg_color))
            .to eq "^bg()^fg(#{fg_color})test^bg()^fg()"

          expect(dzen2.colorize('test', bg: bg_color))
            .to eq "^bg(#{bg_color})^fg()test^bg()^fg()"

          expect(dzen2.colorize('test', fg: fg_color, bg: fg_color))
            .to eq "^bg(#{fg_color})^fg(#{fg_color})test^bg()^fg()"
        end
      end

      it 'colorizes what a block passed to it returns' do
        fg_color = random_color

        expect(dzen2.colorize(fg: fg_color) { 'test' }).to eq "^bg()^fg(#{fg_color})test^bg()^fg()"
      end

      it 'supports nested colorizing' do
        first = {bg: random_color}
        second = {fg: random_color}
        third = {bg: random_color, fg: random_color}

        expected = "^bg(#{first[:bg]})^fg()" <<
                     "first" <<
                     "^bg(#{first[:bg]})^fg(#{second[:fg]})" <<
                       "second" <<
                       "^bg(#{third[:bg]})^fg(#{third[:fg]})" <<
                         "third" <<
                       "^bg(#{first[:bg]})^fg(#{second[:fg]})" <<
                     "^bg(#{first[:bg]})^fg()" <<
                     "more for first" <<
                   "^bg()^fg()"

        actual = dzen2.colorize(first) do
          result_first = "first" 
          result_first << dzen2.colorize(second) do
            "second" + dzen2.colorize("third", third)
          end
          result_first + "more for first"
        end

        expect(actual).to eq expected
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

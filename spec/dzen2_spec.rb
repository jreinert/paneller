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
  end

end

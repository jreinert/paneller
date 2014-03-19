require 'colorable'
include Colorable

# Formatters provide helper methods used by Widgets to format strings

module Formatters

  # Provides helper methods for formatting strings for dzen2

  module Dzen2

    # Sets back- and foreground colors of a string.
    #
    # @param [Hash] colors The colors to use for this string.
    #
    # @option colors [String, Array<Integer>, Symbol] :fg The foreground color.
    #   The last used foreground color will be used per default.
    #   Can be a hex string, an array of three rgb integer values in 0..255
    #   or a symbol (or string) with a color name.
    #
    # @option colors [String, Array<Integer>, Symbol] :bg The background color.
    #   See +:fg+ for types.
    #   The last used background color will be used per default.
    #
    # @overload colorize(string, colors)
    #
    # @param [String] string The string to colorize.
    #
    # @overload colorize(colors, &block)
    #
    # @yieldreturn [String] The string to colorize

    def colorize(string=nil, colors, &block)

      colors[:bg] ||= @color_stack.last[:bg]
      colors[:fg] ||= @color_stack.last[:fg]

      @color_stack.push(colors)
      result = color_setting_string(colors)

      result << string || yield

      @color_stack.pop
      result << color_setting_string(@color_stack.last)
    end

    private

    def color_setting_string(colors)
      bg = colors[:bg] ? Color.new(colors[:bg]).hex : ''
      fg = colors[:fg] ? Color.new(colors[:fg]).hex : ''

      result = ''
      result << "^bg(#{bg})"
      result << "^fg(#{fg})"

      result
    end

  end

end

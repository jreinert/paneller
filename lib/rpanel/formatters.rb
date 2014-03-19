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
    # @option colors [Colorize::Color] :fg The foreground color.
    #   The last used foreground color will be used per default.
    #
    # @option colors [Colorize::Color] :bg The background color.
    #   The last used background color will be used per default.
    #
    # @overload colorize(colors, string)
    #
    # @param [String] string The string to colorize.
    #
    # @overload colorize(colors, &block)
    #
    # @yieldreturn [String] The string to colorize

    def colorize(colors, string=nil, &block)
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
      bg = colors[:bg] ? colors[:bg].hex : ''
      fg = colors[:fg] ? colors[:fg].hex : ''

      "^bg(#{bg})^fg(#{fg})"
    end

  end

end

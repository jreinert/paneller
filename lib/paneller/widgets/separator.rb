require 'paneller/widget'

module Paneller
  class Separator
    include Widget

    def initialize(sep_string = ' | ')
      super(initial_content: sep_string)
      @sep_string = sep_string
    end

    def poll_content
      yield @sep_string
    end
  end
end

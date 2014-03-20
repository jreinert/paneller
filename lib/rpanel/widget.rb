require 'observer'
require 'rpanel/formatters'

# A Segment in a {Panel} used to display various information Widgets run in
# separate threads, can be polled for their content and notify observers
# ({Panel}s) about changed content.

module Rpanel::Widget
  include Observable

  @@id_counter = 0

  # Options to use when omitted in {#initialize}
  #
  # @see #initialize

  DEFAULT_OPTIONS = {
    initial_content: '--Loading--',
    update_interval: 5,
    formatter: Formatters::Dzen2
  }

  attr_reader :id

  # Initializes a new Widget
  #
  # @param [Hash] options options for the widget
  #
  # @option options [#to_s] :initial_content ('--Loading--')
  #   content to show before any content is loaded
  # @option options [#to_f] :update_interval (5)
  #   amount of seconds to wait between refreshes
  # @option options [Module] :formatter ({Formatters::Dzen})
  #   formatter to use for helper methods

  def initialize(options = {})
    @id = @@id_counter
    @@id_counter += 1

    @options = DEFAULT_OPTIONS.merge(options)
    @content = @options[:initial_content]
    extend @options[:formatter]
  end

  # Outputs the current content of the Widget as a String

  def to_s
    @content
  end

  # Starts polling for content and notifies any observers on changes

  def run
    first_run = true

    poll_content do |content|
      sleep @options[:update_interval].to_f unless first_run
      if content != @content
        changed
        @content = content

        notify_observers(id, content)
      end
      first_run = false
    end
  end

  # Polls the content for the widget
  #
  # @yield Yields the formatted content for this widget
  # @yieldparam [String] content the content

  def poll_content(&block)
    raise NameError.new("Not implemented")
  end

end

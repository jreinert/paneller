# A Panel aggregates content from Widgets and flushes it to an IO object
# whenever a widgets content has changed

class Paneller::Panel

  # Initializes the Panel
  #
  # @param [#puts] output the IO to write output to

  def initialize(output = STDOUT)
    @output = output
    @widgets = {}
  end

  # Subscribes to the given widget
  #
  # The panel will be notified every time the content of the widget changes
  #
  # @param [Widget] widget the widget to subscribe to

  def register_widget(widget)
    unless @widgets[widget.id]
      widget.add_observer(self)
      @widgets[widget.id] = widget.to_s
    end
  end

  # Flushes the current content of all registered widgets to the +output+

  def flush
    @output.puts @widgets.values.join
  end

  # Called whenever the content of any subscribed Widget changes.
  # Sets the new widget content and flushes to +output+

  def update(widget_id, new_content)
    @widgets[widget_id] = new_content
    flush
  end

end

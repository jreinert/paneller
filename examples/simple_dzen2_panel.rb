require 'paneller/panel'
require 'paneller/widget'
require 'paneller/widgets/separator'
require 'open3'

DZEN_COMMAND = 'dzen2 -y -1 -ta r -fn "DejaVu Sans-10"'

# Define some widgets

class TimeWidget
  include Paneller::Widget

  def poll_content 
    loop do
      yield Time.now.strftime('%Y-%m-%d - %H:%M')
    end
  end
end

class MemWidget
  include Paneller::Widget

  MEM_REGEXP = /Mem:\s+(?<total>\S+)\s+(?<used>\S+)\s+(?<free>\S+)/

  def poll_content
    loop do
      free_output = MEM_REGEXP.match(`free -h`)
      yield "#{free_output[:used]}/#{free_output[:total]}"
    end
  end
end

widgets = []
widgets << TimeWidget.new(update_interval: 1)
widgets << Paneller::Separator.new
widgets << MemWidget.new(update_interval: 30)

# Open up a pipe to dzen2

Open3.popen2e(DZEN_COMMAND) do |dzen_in, dzen_out|
  # Create a panel that uses dzens stdin as output

  panel = Paneller::Panel.new(dzen_in)

  # Register the widgets to the panel

  widgets.each do |widget|
    panel.register_widget(widget)
  end

  # Start the widgets

  threads = widgets.map do |widget|
    Thread.new { widget.run }
  end

  threads.map { |t| t.join  }
end

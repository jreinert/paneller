require 'rpanel/panel'

module Rpanel
  describe Panel do

    it 'can subscribe to Widgets' do
      panel = Panel.new()

      widget = double("widget", add_observer: nil, id: 0)

      panel.register_widget(widget)

      expect(widget).to have_received(:add_observer).with(panel)
    end

    it 'can flush its current content to the given IO object' do
      io = double("io", puts: nil)
      panel = Panel.new(io)

      expected_output = ''
      (1..5).each do |i|
        output = "test output #{i}"
        widget = double(add_observer: nil, id: i, to_s: output)
        expected_output << output

        panel.register_widget(widget)
      end

      panel.flush

      expect(io).to have_received(:puts).with(expected_output)
    end

    it 'sets and flushes its content whenever it receives an update' do
      io = double("io", puts: nil)
      panel = Panel.new(io)

      widget = double("widget", add_observer: nil, id: 0)
      panel.register_widget(widget)

      expected_content = 'new content'
      panel.update(widget.id, expected_content)

      expect(io).to have_received(:puts).with(expected_content)
    end

  end
end

require 'rpanel/widget'

module Rpanel
  describe Widget do
    let(:widget_class) { Class.new { include Widget } }
    let(:formatter_module) { Module.new {  } }
    let(:some_content) { rand(36**16).to_s(36) }

    describe '.new' do

      describe 'options' do

        it 'accepts a formatter in its options and extend itself with it' do
          widget = widget_class.new(formatter: formatter_module)

          expect(widget).to be_a formatter_module
        end

        it 'accepts an initial content in its options and sets the content to it' do
          widget = widget_class.new(initial_content: some_content)

          expect(widget.to_s).to eq some_content
        end

        it 'uses default options if none are provided' do
          widget = widget_class.new

          expect(widget.to_s).to eq Widget::DEFAULT_OPTIONS[:initial_content]
          expect(widget).to be_a Widget::DEFAULT_OPTIONS[:formatter]
        end

      end

      it 'receives a unique id' do
        used_ids = []

        1000.times do
          widget = widget_class.new

          expect(used_ids).not_to include widget.id
          used_ids << widget.id
        end
      end

    end

    describe '#poll_content' do

      let(:widget) { widget_class.new }

      it 'throws an error if not overridden' do
        expect { widget.poll_content }.to raise_error(NameError)
      end

    end

    describe '#run' do

      let(:interval) { 0.01 }
      let(:widget) { widget_class.new(update_interval: interval) }

      it 'calls #poll_content and sets the content to what it yields' do

        allow(widget).to receive(:poll_content).and_yield(some_content)

        widget.run

        expect(widget.to_s).to eq some_content
      end

      it 'waits the amount of time specified in options between consecutive polls' do
        iterations = 3
        pauses = iterations - 1

        (1..iterations).inject(allow(widget).to receive(:poll_content)) do |receive|
          receive.and_yield('content')
        end

        start_time = Time.now
        widget.run
        end_time = Time.now

        expect(end_time - start_time).to be_within(0.001).of(pauses * interval)
      end

      it 'notifies observers about changes' do
        observer = double('observer', update: nil)
        some_other_content = "#{some_content} and more"

        allow(widget).to receive(:poll_content).and_yield(some_content).and_yield(some_other_content)

        widget.add_observer(observer)
        widget.run

        expect(observer).to have_received(:update).twice
        expect(observer).to have_received(:update).with(widget.id, some_content)
        expect(observer).to have_received(:update).with(widget.id, some_other_content)
      end

      it 'only notifies observers when the content has changed' do
        observer = double('observer', update: nil)

        allow(widget).to receive(:poll_content).and_yield(some_content).and_yield(some_content)

        widget.add_observer(observer)
        widget.run

        expect(observer).to have_received(:update).once
      end

    end

  end
end

# frozen_string_literal: true

require 'spec_helper'

describe Crystalball::MapGenerator::CoverageStrategy::SharedSetup do
  let(:detector) { instance_double(Crystalball::MapGenerator::CoverageStrategy::ExecutionDetector) }
  let(:tracker) { described_class.new(detector) }
  let(:group) { double('group') }
  let(:notification) { double(group: group) }

  it 'rejects unbalanced group events instead of attributing setup to another group' do
    tracker.start(nil)
    expect { tracker.example_group_finished(notification) }.to raise_error('Unbalanced RSpec group notifications')
  end

  it 'stops observing after collection finishes' do
    tracker.start(nil)
    tracker.close
    expect(Coverage).not_to receive(:peek_result)
    tracker.example_group_started(notification)
    expect(tracker.files_for(nil)).to eq([])
  end

  it 'does not retain dependencies from an earlier collection session' do
    allow(detector).to receive(:detect).and_return(['old.rb'], ['new.rb'])
    example = double(example_group: double(parent_groups: []))
    tracker.start(nil)
    tracker.capture(Coverage.peek_result)
    expect(tracker.files_for(example)).to eq(['old.rb'])
    tracker.close
    tracker.start(nil)
    tracker.capture(Coverage.peek_result)
    expect(tracker.files_for(example)).to eq(['new.rb'])
  end
end

# frozen_string_literal: true

require 'open3'
require 'rbconfig'

require 'spec_helper'

describe Crystalball::MapGenerator::AllocatedObjectsStrategy::ObjectTracker do
  subject(:tracker) { described_class.new }

  it 'loads Set when required in an isolated Ruby process' do
    command = <<~RUBY
      require 'crystalball/map_generator/allocated_objects_strategy/object_tracker'
      Crystalball::MapGenerator::AllocatedObjectsStrategy::ObjectTracker.new
    RUBY
    output, status = Open3.capture2e(RbConfig.ruby, '-Ilib', '-e', command)

    expect(status).to be_success, output
  end

  before do
    stub_const('Dummy', Class.new)
    stub_const('SubDummy', Class.new(Dummy))
  end

  describe '#used_classes_during' do
    it 'returns objects allocated during a block' do
      expect(tracker.used_classes_during { Dummy.allocate }).to match_array(Dummy)
    end

    it 'returns objects created during a block' do
      expect(tracker.used_classes_during do
        Dummy.new
        Object.new
      end).to match_array([Object, Dummy])
    end

    it 'empty array if no objects were allocated' do
      expect(tracker.used_classes_during { Dummy.class }).to be_empty
    end

    context 'with only_of specified' do
      subject(:tracker) { described_class.new(only_of: ['Dummy']) }

      it 'ignores created objects of other classes' do
        expect(tracker.used_classes_during do
          Dummy.new
          Object.new
        end).to match_array(Dummy)
      end

      it 'lists subclasses too' do
        expect(tracker.used_classes_during { SubDummy.new }).to match_array(SubDummy)
      end
    end
  end
end

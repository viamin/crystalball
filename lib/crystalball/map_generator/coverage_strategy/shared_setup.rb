# frozen_string_literal: true

module Crystalball
  class MapGenerator
    class CoverageStrategy
      # RSpec group notifications bracket shared setup without replacing its hooks.
      class SharedSetup
        def initialize(detector)
          @detector = detector
          @groups = []
          @dependencies = Hash.new { |hash, group| hash[group] = [] }
        end

        def start(_notification)
          @groups.clear
          @dependencies.clear
          @recording = true
          @pending = true
          @snapshot = Coverage.peek_result
        end

        def example_group_started(notification)
          return unless @recording

          current = Coverage.peek_result
          capture(current)
          @groups << notification.group
          @snapshot = current
          @pending = true
        end

        def example_group_finished(notification)
          return unless @recording

          raise 'Unbalanced RSpec group notifications' unless @groups.pop == notification.group

          @pending = false
        end

        def capture(current)
          return unless @recording && @pending

          @dependencies[@groups.last].concat(@detector.detect(@snapshot, current))
          @pending = false
        end

        def files_for(example)
          return [] unless @recording

          @dependencies[nil] + example.example_group.parent_groups.flat_map { |group| @dependencies[group] }
        end

        def close
          @recording = false
          @pending = false
          @snapshot = nil
          @groups.clear
          @dependencies.clear
        end
      end
    end
  end
end

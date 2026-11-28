# frozen_string_literal: true

module Crystalball
  class MapGenerator
    class FactoryBotStrategy
      # Module to add new `run` method to FactoryBot::FactoryRunner
      module FactoryRunnerPatch
        class << self
          # Patches `FactoryBot::FactoryRunner#run`.
          def apply!
            FactoryBotStrategy.factory_bot_constant::FactoryRunner.prepend FactoryRunnerPatch
          end
        end

        # Overrides `FactoryBot::FactoryRunner#run`. Pushes factory name to
        # `FactoryBotStrategy.used_factories` and calls original `run`
        def run(*)
          registry = FactoryBotStrategy.factory_bot_constant
          registry = registry::Internal unless registry.respond_to?(:factory_by_name)
          factory = registry.factory_by_name(@name)
          FactoryBotStrategy.used_factories << factory.name.to_s
          super
        end
      end
    end
  end
end

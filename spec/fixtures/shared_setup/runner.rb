# frozen_string_literal: true

require 'json'
require 'simplecov'
SimpleCov.coverage_dir(File.join(ARGV.fetch(0), 'coverage'))
SimpleCov.start
require 'crystalball'
require 'active_record'
require 'sqlite3'
require 'factory_bot'
require 'test_prof/recipes/rspec/let_it_be'

ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: ':memory:')
ActiveRecord::Schema.define do
  create_table(:setup_records) { |table| table.string :value }
end

class SetupRecord < ActiveRecord::Base; end

Dir[File.join(__dir__, 'dependencies', '*.rb')].sort.each { |file| require file }
FactoryBot.define do
  factory :setup_record do
    value { SetupFactoryDependency.value }
  end
end

before_registration = Coverage.peek_result
collect = ENV.fetch('COLLECT_SHARED_SETUP', 'true') == 'true'
if collect
  Crystalball::MapGenerator.start! do |config|
    config.map_storage_path = File.join(ARGV.fetch(0), 'map.yml')
    config.compact_map = false
    config.register Crystalball::MapGenerator::CoverageStrategy.new
  end
end
after_registration = Coverage.peek_result
counters_preserved = before_registration.all? do |file, data|
  data.fetch(:lines).zip(after_registration.fetch(file).fetch(:lines)).all? do |before, after|
    before.nil? || after.to_i >= before
  end
end

RSpec.configure { |config| config.before(:suite) { SetupSuiteDependency.value } }
paths = Dir[File.join(__dir__, '*_examples.rb')].sort
started_at = Process.clock_gettime(Process::CLOCK_MONOTONIC)
status = RSpec::Core::Runner.run(paths + ['--format', 'progress', '--seed', ARGV.fetch(1)])
elapsed = Process.clock_gettime(Process::CLOCK_MONOTONIC) - started_at
maps = {}
selected = {}
if collect
  map = Crystalball::MapStorage::YAMLStorage.load(Pathname(File.join(ARGV.fetch(0), 'map.yml')))
  examples = RSpec.world.all_examples
  maps = examples.to_h { |example| [example.full_description, map.example_groups.fetch(example.id)] }
  %w[parent child factory suite sibling].each do |source|
    path = "spec/fixtures/shared_setup/dependencies/#{source}.rb"
    diff = Crystalball::SourceDiff::FileDiff.new(Git::Diff::DiffFile.new(Git::Base.new, path: path))
    prediction = Crystalball::Predictor::ModifiedExecutionPaths.new.call([diff], map)
    selected[source] = examples.select { |example| prediction.include?(example.id) }.map(&:full_description)
  end
end
puts "SHARED_SETUP_RESULT=#{JSON.generate(maps: maps, selected: selected, counters_preserved: counters_preserved, elapsed_seconds: elapsed)}"
exit(status)

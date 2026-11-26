# frozen_string_literal: true

require 'json'
require 'open3'
require 'rbconfig'
require 'tmpdir'

require 'spec_helper'

describe 'coverage collection with SimpleCov' do
  it 'keeps SimpleCov coverage active and collects files without restarting Coverage' do
    script = <<~'RUBY'
      require 'fileutils'
      require 'json'
      require 'simplecov'
      require 'tmpdir'

      SimpleCov.start
      require 'crystalball'

      initial_coverage = Coverage.peek_result
      probe_directory = nil
      begin
        probe_directory = Dir.mktmpdir('crystalball-coverage-probe', Dir.pwd)
        probe_path = File.join(probe_directory, 'probe.rb')
        File.write(probe_path, "COVERAGE_PROBE = true\n")

        collected_files = []
        example_map = Object.new
        example_map.define_singleton_method(:push) { |*files| collected_files.concat(files) }

        strategy = Crystalball::MapGenerator::CoverageStrategy.new
      strategy.after_register
      coverage_after_registration = Coverage.peek_result
      counters_preserved = initial_coverage.all? do |file, initial_result|
        registered_result = coverage_after_registration.fetch(file)
        initial_result.fetch(:lines).zip(registered_result.fetch(:lines)).all? do |initial_count, registered_count|
          initial_count.nil? || registered_count.to_i >= initial_count
        end
      end
        strategy.call(example_map, nil) { load probe_path }

        puts "CRYSTALBALL_RESULT=#{JSON.generate(
          running: Coverage.running?,
        counters_preserved: counters_preserved,
          collected: collected_files.include?(probe_path.delete_prefix("#{Dir.pwd}/"))
        )}"
      ensure
        FileUtils.rm_rf(probe_directory) if probe_directory
      end
    RUBY

    output, status = Open3.capture2e(RbConfig.ruby, '-Ilib', '-e', script)

    expect(status).to be_success, output
    result = JSON.parse(output.lines.grep(/^CRYSTALBALL_RESULT=/).last.delete_prefix('CRYSTALBALL_RESULT='))

    expect(result).to eq('running' => true, 'counters_preserved' => true, 'collected' => true)
  end
end

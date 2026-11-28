# frozen_string_literal: true

require 'open3'
require 'rbconfig'

require 'spec_helper'

RSpec.describe 'standard library dependencies' do
  it 'declares runtime and development dependencies compatible with its support policy' do
    specification = Gem::Specification.load('crystalball.gemspec')

    expect(specification.required_ruby_version).to eq(Gem::Requirement.new('>= 3.4'))
    expect(specification.runtime_dependencies.find { |dependency| dependency.name == 'git' }.requirement)
      .to eq(Gem::Requirement.new('>= 1.13', '< 4.0'))
  end

  it 'loads files using Forwardable in isolated Ruby processes' do
    forwardable_files.each do |path|
      output, status = Open3.capture2e(RbConfig.ruby, '--disable-gems', '-Ilib', '-e', "require '#{path}'")

      expect(status).to be_success, output
    end
  end

  def forwardable_files
    %w[
      crystalball/example_group_map
      crystalball/execution_map
      crystalball/map_generator
      crystalball/map_generator/allocated_objects_strategy
      crystalball/map_generator/described_class_strategy
      crystalball/rails/tables_map
      crystalball/rails/tables_map_generator
    ]
  end
end

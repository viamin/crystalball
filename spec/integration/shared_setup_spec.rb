# frozen_string_literal: true

require 'json'
require 'open3'
require 'rbconfig'
require 'tmpdir'
require 'spec_helper'

describe 'shared setup coverage' do
  [17, 493].each do |seed|
    it "preserves context and fixture dependencies with randomized seed #{seed}" do
      Dir.mktmpdir('shared-setup-map') do |directory|
        output, status = Open3.capture2e(RbConfig.ruby, '-Ilib', 'spec/fixtures/shared_setup/runner.rb', directory, seed.to_s)
        expect(status).to be_success, output
        result = JSON.parse(output.lines.grep(/^SHARED_SETUP_RESULT=/).last.delete_prefix('SHARED_SETUP_RESULT='))
        maps = result.fetch('maps')
        dependency = ->(name) { "spec/fixtures/shared_setup/dependencies/#{name}.rb" }

        expect(maps.size).to eq(9)
        expect(result.fetch('counters_preserved')).to be(true)
        maps.each_value { |files| expect(files).to include(dependency.call('suite')) }
        maps.select { |name, _| name.start_with?('parent ') }.each_value do |files|
          expect(files).to include(dependency.call('parent'))
        end
        maps.select { |name, _| name.include?('nested') }.each_value do |files|
          expect(files).to include(dependency.call('child'))
        end
        maps.select { |name, _| name.start_with?('fixtures ') }.each_value do |files|
          expect(files).to include(dependency.call('factory'))
        end
        sibling = maps.fetch('sibling keeps its own dependency')
        expect(sibling).to include(dependency.call('sibling'))
        expect(sibling).not_to include(dependency.call('parent'), dependency.call('child'), dependency.call('factory'))
        selected = result.fetch('selected')
        expect(selected.fetch('parent')).to match_array(maps.keys.grep(/^parent /))
        expect(selected.fetch('child')).to match_array(maps.keys.grep(/nested/))
        expect(selected.fetch('factory')).to match_array(maps.keys.grep(/^fixtures /))
        expect(selected.fetch('suite')).to match_array(maps.keys)
        expect(selected.fetch('sibling')).to eq(['sibling keeps its own dependency'])
      end
    end
  end
end

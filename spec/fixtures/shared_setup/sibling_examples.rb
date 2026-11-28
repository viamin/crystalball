# frozen_string_literal: true

RSpec.describe 'sibling' do
  it('keeps its own dependency') { expect(SetupSiblingDependency.value).to eq('sibling') }
end

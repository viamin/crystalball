# frozen_string_literal: true

RSpec.describe 'parent' do
  before(:context) { @parent_value = SetupParentDependency.value }

  it('first consumes shared state') { expect(@parent_value).to eq('parent') }
  it('second consumes shared state') { expect(@parent_value).to eq('parent') }

  context 'nested' do
    before(:context) { @child_value = SetupChildDependency.value }
    it('consumes both levels') { expect([@parent_value, @child_value]).to eq(%w[parent child]) }

    context 'deeper' do
      it('inherits both levels') { expect([@parent_value, @child_value]).to eq(%w[parent child]) }
    end
  end
end

RSpec.describe 'parent with only child groups' do
  before(:context) { @parent_value = SetupParentDependency.value }

  context 'left' do
    it('inherits shared state') { expect(@parent_value).to eq('parent') }
  end

  context 'right' do
    it('inherits shared state') { expect(@parent_value).to eq('parent') }
  end
end

# frozen_string_literal: true

RSpec.describe 'fixtures' do
  before_all { @before_all_record = FactoryBot.create(:setup_record) }
  let_it_be(:persistent_record) { FactoryBot.create(:setup_record) }

  it('consumes before_all state') { expect(@before_all_record.value).to eq('factory') }
  it('consumes let_it_be state') { expect(persistent_record.value).to eq('factory') }
end

require 'rails_helper'

RSpec.describe Wishes::Realise, type: :service do
  subject(:call_service) { described_class.call(wish_id: wish.id) }

  let(:wish) { create(:wish, state: :active) }

  it 'delegates to Wishes::Commands::RealiseWish' do
    expect(Wishes::Commands::RealiseWish).to receive(:call).with(wish_id: wish.id).and_call_original
    call_service
  end

  it 'returns the result from command' do
    result = call_service

    expect(result).to be_success
    realised_wish = result.value!
    expect(realised_wish.state).to eq('realised')
  end
end

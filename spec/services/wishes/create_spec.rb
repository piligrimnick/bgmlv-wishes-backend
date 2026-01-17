require 'rails_helper'

RSpec.describe Wishes::Create, type: :service do
  subject(:call_service) { described_class.call(**params) }
  let(:params) { { user_id: user_id, wish: wish_attributes } }

  let(:user_id) { create(:user).id }
  let(:wish_attributes) { { body: 'body', url: 'url' } }

  it 'creates a wish' do
    expect { call_service }.to change(Wish, :count).by(1)
    
    # Result is a Dry::Monads::Result
    expect(subject).to be_success
    expect(subject.value!).to be_a(Wish)
    expect(subject.value!.user_id).to eq(user_id)
    expect(subject.value!.body).to eq(wish_attributes[:body])
    expect(subject.value!.url).to eq(wish_attributes[:url])
  end
end

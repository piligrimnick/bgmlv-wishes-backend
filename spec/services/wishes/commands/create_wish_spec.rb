require 'rails_helper'

RSpec.describe Wishes::Commands::CreateWish, type: :service do
  subject(:create_wish) { described_class.call(**params) }

  let(:user) { create(:user) }

  describe '#call' do
    context 'with minimal params' do
      let(:params) { { user_id: user.id } }

      it { expect { create_wish }.to change(Wish, :count).by(1) }

      it { is_expected.to be_success }

      it 'creates wish for user' do
        expect(create_wish.value!.user_id).to eq(user.id)
      end
    end

    context 'with body and url' do
      let(:params) do
        {
          user_id: user.id,
          body: 'Test wish',
          url: 'https://example.com'
        }
      end

      it 'creates wish with attributes' do
        wish = create_wish.value!

        expect(wish.body).to eq('Test wish')
        expect(wish.url).to eq('https://example.com')
      end
    end

    context 'with picture' do
      let(:picture) { Rack::Test::UploadedFile.new(Rails.root.join('spec/fixtures/test_image.jpg'), 'image/jpeg') }
      let(:params) { { user_id: user.id, body: 'Wish with picture', picture: picture } }

      before do
        FileUtils.mkdir_p(Rails.root.join('spec/fixtures'))
        Rails.root.join('spec/fixtures/test_image.jpg').write('fake image data') unless Rails.root.join('spec/fixtures/test_image.jpg').exist?
      end

      it 'attaches picture' do
        expect(create_wish.value!.picture).to be_attached
      end

      it 'saves with correct filename pattern' do
        expect(create_wish.value!.picture.filename.to_s).to match(/\d+_test_image\.jpg/)
      end
    end

    context 'with picture without original_filename' do
      let(:picture) { StringIO.new('fake image data') }
      let(:params) { { user_id: user.id, picture: picture } }

      it 'uses default filename' do
        expect(create_wish.value!.picture.filename.to_s).to match(/\d+_image/)
      end
    end

    context 'with invalid user_id' do
      let(:params) { { user_id: 999_999 } }

      it { is_expected.to be_failure }

      it { expect { create_wish }.not_to change(Wish, :count) }
    end

    context 'when creation fails' do
      let(:params) { { user_id: user.id, body: 'Test' } }

      before { allow(Wish).to receive(:create!).and_raise(ActiveRecord::RecordInvalid.new(Wish.new)) }

      it { is_expected.to be_failure }
    end
  end
end

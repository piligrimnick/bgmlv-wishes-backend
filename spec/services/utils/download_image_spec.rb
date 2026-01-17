require 'rails_helper'

RSpec.describe Utils::DownloadImage, type: :service do
  subject(:call_service) { described_class.call(url: url) }

  let(:tempfile) { double('tempfile', content_type: 'image/jpeg', close!: nil) }

  context 'with valid image url' do
    let(:url) { 'https://example.com/image.jpg' }

    before do
      allow(Down).to receive(:download).and_return(tempfile)
    end

    it 'downloads the image' do
      expect(Down).to receive(:download).with(
        url,
        headers: { 'User-Agent' => described_class::USER_AGENT },
        open_timeout: 5,
        read_timeout: 10,
        max_redirects: 5
      )

      call_service
    end

    it 'returns the tempfile' do
      result = call_service
      expect(result).to eq(tempfile)
    end
  end

  context 'with blank url' do
    let(:url) { nil }

    it 'returns nil' do
      expect(call_service).to be_nil
    end

    it 'does not attempt download' do
      expect(Down).not_to receive(:download)
      call_service
    end
  end

  context 'with empty url' do
    let(:url) { '' }

    it 'returns nil' do
      expect(call_service).to be_nil
    end
  end

  context 'when content type is not an image' do
    let(:url) { 'https://example.com/document.pdf' }
    let(:pdf_file) { double('pdf_file', content_type: 'application/pdf', close!: nil) }

    before do
      allow(Down).to receive(:download).and_return(pdf_file)
    end

    it 'closes the file' do
      expect(pdf_file).to receive(:close!)
      call_service
    end

    it 'returns nil' do
      expect(call_service).to be_nil
    end
  end

  context 'when download fails with Down::Error' do
    let(:url) { 'https://example.com/invalid.jpg' }

    before do
      allow(Down).to receive(:download).and_raise(Down::NotFound.new('Not found'))
      allow(Rails.logger).to receive(:error)
    end

    it 'logs the error' do
      expect(Rails.logger).to receive(:error).with(/Failed to download image/)
      call_service
    end

    it 'returns nil' do
      expect(call_service).to be_nil
    end
  end

  context 'when download fails with unexpected error' do
    let(:url) { 'https://example.com/image.jpg' }

    before do
      allow(Down).to receive(:download).and_raise(StandardError.new('Unexpected'))
      allow(Rails.logger).to receive(:error)
    end

    it 'logs the unexpected error' do
      expect(Rails.logger).to receive(:error).with(/Unexpected error downloading image/)
      call_service
    end

    it 'returns nil' do
      expect(call_service).to be_nil
    end
  end

  context 'with different image content types' do
    let(:url) { 'https://example.com/image.png' }

    %w[image/png image/gif image/webp image/svg+xml].each do |content_type|
      context "with #{content_type}" do
        let(:image_file) { double('image_file', content_type: content_type, close!: nil) }

        before do
          allow(Down).to receive(:download).and_return(image_file)
        end

        it 'accepts the image' do
          expect(call_service).to eq(image_file)
        end
      end
    end
  end
end

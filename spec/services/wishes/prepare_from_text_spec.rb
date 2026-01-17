require 'rails_helper'

RSpec.describe Wishes::PrepareFromText, type: :service do
  subject(:call_service) { described_class.call(text) }

  let(:text) { 'Simple wish text' }

  context 'with plain text without URL' do
    let(:text) { 'I want a new book' }

    before do
      allow(Utils::ParseUrl).to receive(:call).with(text: text).and_return(nil)
    end

    it 'returns body and nil url' do
      result = call_service

      expect(result[:body]).to eq('I want a new book')
      expect(result[:url]).to be_nil
    end
  end

  context 'with text containing URL' do
    let(:text) { 'Check this https://example.com' }
    let(:metadata_response) { double(status: 200) }
    let(:metadata) do
      instance_double(
        MetaInspector::Document,
        response: metadata_response,
        best_title: 'Example Title',
        best_description: 'Example Description',
        canonicals: [{ href: 'https://example.com/canonical' }],
        images: double(best: 'https://example.com/image.jpg')
      )
    end

    before do
      allow(Utils::ParseUrl).to receive(:call).with(text: text).and_return('https://example.com')
      allow(MetaInspector).to receive(:new).and_return(metadata)
      allow(Utils::DownloadImage).to receive(:call).and_return(nil)
    end

    it 'enriches body with metadata' do
      result = call_service

      expect(result[:body]).to include('Check this')
      expect(result[:body]).to include('Example Title')
      expect(result[:body]).to include('Example Description')
      expect(result[:url]).to eq('https://example.com/canonical')
    end

    it 'removes URL from body' do
      result = call_service

      expect(result[:body]).not_to include('https://example.com')
    end

    it 'downloads image' do
      expect(Utils::DownloadImage).to receive(:call).with(url: 'https://example.com/image.jpg')
      call_service
    end

    it 'attaches downloaded picture' do
      tempfile = double('tempfile')
      allow(Utils::DownloadImage).to receive(:call).and_return(tempfile)

      result = call_service
      expect(result[:picture]).to eq(tempfile)
    end
  end

  context 'when metadata response is not 200' do
    let(:text) { 'Check https://example.com' }

    before do
      allow(Utils::ParseUrl).to receive(:call).and_return('https://example.com')
      allow(MetaInspector).to receive(:new).and_return(
        instance_double(MetaInspector::Document, response: double(status: 404))
      )
    end

    it 'returns text and url without enrichment' do
      result = call_service

      expect(result[:body]).to eq(text)
      expect(result[:url]).to eq('https://example.com')
      expect(result[:picture]).to be_nil
    end
  end

  context 'when metadata has no canonicals' do
    let(:text) { 'Check https://example.com' }

    before do
      allow(Utils::ParseUrl).to receive(:call).and_return('https://example.com')
      allow(MetaInspector).to receive(:new).and_return(
        instance_double(
          MetaInspector::Document,
          response: double(status: 200),
          best_title: 'Title',
          best_description: 'Description',
          canonicals: [],
          images: double(best: nil)
        )
      )
      allow(Utils::DownloadImage).to receive(:call).and_return(nil)
    end

    it 'uses original url' do
      result = call_service
      expect(result[:url]).to eq('https://example.com')
    end
  end

  context 'when metadata enrichment results in blank body' do
    let(:text) { 'https://example.com' }

    before do
      allow(Utils::ParseUrl).to receive(:call).and_return('https://example.com')
      allow(MetaInspector).to receive(:new).and_return(
        instance_double(
          MetaInspector::Document,
          response: double(status: 200),
          best_title: nil,
          best_description: nil,
          canonicals: [],
          images: double(best: nil)
        )
      )
      allow(Utils::DownloadImage).to receive(:call).and_return(nil)
    end

    it 'falls back to original text' do
      result = call_service
      expect(result[:body]).to eq(text)
    end
  end

  context 'when MetaInspector raises RequestError' do
    let(:text) { 'Check https://example.com' }

    before do
      allow(Utils::ParseUrl).to receive(:call).and_return('https://example.com')
      allow(MetaInspector).to receive(:new).and_raise(MetaInspector::RequestError.new('Failed'))
    end

    it 'returns text and url without enrichment' do
      result = call_service

      expect(result[:body]).to eq(text)
      expect(result[:url]).to eq('https://example.com')
      expect(result[:picture]).to be_nil
    end
  end

  context 'with custom user agent' do
    let(:text) { 'https://example.com' }

    before do
      allow(Utils::ParseUrl).to receive(:call).and_return('https://example.com')
      allow(MetaInspector).to receive(:new).and_call_original
      allow(Utils::DownloadImage).to receive(:call).and_return(nil)
    end

    it 'passes user agent to MetaInspector' do
      expect(MetaInspector).to receive(:new).with(
        'https://example.com',
        hash_including(headers: { 'User-Agent' => described_class::USER_AGENT })
      )

      call_service
    end
  end
end

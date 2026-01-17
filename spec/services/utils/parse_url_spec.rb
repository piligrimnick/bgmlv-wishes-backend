require 'rails_helper'

RSpec.describe Utils::ParseUrl, type: :service do
  subject(:call_service) { described_class.call(text: text) }

  context 'with text containing a URL' do
    let(:text) { 'Check out this link https://example.com for more info' }

    it 'extracts the first URL' do
      expect(call_service).to eq('https://example.com')
    end
  end

  context 'with text containing multiple URLs' do
    let(:text) { 'Visit https://example.com or https://test.com' }

    it 'returns the first URL only' do
      expect(call_service).to eq('https://example.com')
    end
  end

  context 'with text containing no URLs' do
    let(:text) { 'This is just plain text' }

    it 'returns nil' do
      expect(call_service).to be_nil
    end
  end

  context 'with empty text' do
    let(:text) { '' }

    it 'returns nil' do
      expect(call_service).to be_nil
    end
  end

  context 'with http URL' do
    let(:text) { 'http://example.com' }

    it 'extracts http URL' do
      expect(call_service).to eq('http://example.com')
    end
  end

  context 'with ftp URL' do
    let(:text) { 'ftp://example.com/file.zip' }

    it 'extracts ftp URL' do
      expect(call_service).to eq('ftp://example.com/file.zip')
    end
  end

  context 'with URL with query parameters' do
    let(:text) { 'https://example.com?foo=bar&baz=qux' }

    it 'extracts full URL with parameters' do
      expect(call_service).to eq('https://example.com?foo=bar&baz=qux')
    end
  end
end

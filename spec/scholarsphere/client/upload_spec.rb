# frozen_string_literal: true

RSpec.describe Scholarsphere::Client::Upload do
  let(:upload) { described_class.new(extname: extname, content_md5: content_md5) }
  let(:response) { JSON.parse(upload.body) }

  describe '#create', :vcr do
    context 'with a valid extension' do
      let(:extname) { 'pdf' }
      let(:content_md5) { 'checksum' }

      it 'returns the data' do
        expect(upload.url).to include('content-md5')
        expect(upload.url).to include(extname)
        expect(upload.id).to end_with(extname)
        expect(upload.prefix).to eq('cache')
      end
    end

    context 'with a missing extension' do
      let(:extname) { '' }
      let(:content_md5) { 'checksum' }

      it 'returns an error response' do
        expect { upload.url }.to raise_error(Scholarsphere::Client::Error)
      end
    end
  end
end

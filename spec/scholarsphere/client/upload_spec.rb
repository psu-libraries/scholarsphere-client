# frozen_string_literal: true

RSpec.describe Scholarsphere::Client::Upload do
  let(:upload) { described_class.new(extname: extname) }
  let(:response) { JSON.parse(upload.body) }

  describe '#create' do
    context 'with a valid extension' do
      let(:extname) { 'pdf' }

      it 'returns the data' do
        expect(upload.url).to include(extname)
        expect(upload.id).to end_with(extname)
        expect(upload.prefix).to eq('cache')
      end
    end

    context 'with a missing extension' do
      let(:extname) { '' }

      it 'returns an error response' do
        expect { upload.url }.to raise_error(Scholarsphere::Client::Error)
      end
    end
  end
end

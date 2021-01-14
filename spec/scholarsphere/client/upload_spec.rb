# frozen_string_literal: true

RSpec.describe Scholarsphere::Client::Upload do
  let(:upload) { described_class.create(file: file) }
  let(:file) { instance_spy('Scholarsphere::S3::UploadedFile', key: key) }

  describe '#create' do
    context 'with a valid key' do
      let(:key) { 'prefix/id' }

      it 'returns a presigned url using the supplied key' do
        expect(upload).to be_success
        expect(upload.body).to include(key)
      end
    end

    context 'with an invalid key' do
      let(:key) { '' }

      it 'returns an error response' do
        expect(upload).not_to be_success
        expect(upload.body).to include('Bad request')
      end
    end
  end
end

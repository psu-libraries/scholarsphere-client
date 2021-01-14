# frozen_string_literal: true

require 'scholarsphere/s3'

RSpec.describe Scholarsphere::S3::PresignedUploader do
  let(:path) { fixture_path('image.png') }
  let(:file) { Scholarsphere::S3::UploadedFile.new(path) }
  let(:checksum) { Digest::MD5.hexdigest(path.read) }

  # Use an authenticated client to check if the presigned uploads were successful.
  let(:client) do
    Aws::S3::Client.new(
      endpoint: ENV['S3_ENDPOINT'],
      access_key_id: ENV['AWS_ACCESS_KEY_ID'],
      secret_access_key: ENV['AWS_SECRET_ACCESS_KEY'],
      force_path_style: true,
      region: ENV['AWS_REGION']
    )
  end

  describe '#upload' do
    context 'with the default options' do
      let(:uploader) { described_class.new(file: file) }

      it 'uploads the file to the bucket' do
        response = uploader.upload
        expect(response.status).to eq(200)
        client_response = client.get_object(bucket: ENV['AWS_BUCKET'], key: file.key)
        expect(Digest::MD5.hexdigest(client_response.body.read)).to eq(checksum)
      end
    end

    context 'when providing a failing checksum' do
      let(:uploader) { described_class.new(file: file) }
      let(:file) { Scholarsphere::S3::UploadedFile.new(path, checksum: 'xxx') }

      it 'uploads the file to the bucket' do
        response = uploader.upload
        expect(response.status).to eq(400)
        expect(response.body).to include('BadDigest')
      end
    end
  end
end

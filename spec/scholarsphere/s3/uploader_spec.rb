# frozen_string_literal: true

require 'scholarsphere/s3'

RSpec.describe Scholarsphere::S3::Uploader do
  let(:uploader) { described_class.new }

  it { is_expected.to be_a(Aws::S3::FileUploader) }

  describe '#multipart_threshold' do
    context 'without modification' do
      its(:multipart_threshold) { is_expected.to eq(Aws::S3::FileUploader::FIFTEEN_MEGABYTES) }
    end

    context 'when set to a custom value' do
      subject { described_class.new(multipart_threshold: 1024) }

      its(:multipart_threshold) { is_expected.to eq(1024) }
    end
  end

  describe '#upload' do
    let(:path) { fixture_path('image.png') }
    let(:file) { Scholarsphere::S3::UploadedFile.new(path) }
    let(:checksum) { Digest::MD5.hexdigest(path.read) }

    context 'when using the default options' do
      it 'adds the file to the S3 bucket' do
        uploader.upload(file)
        response = uploader.client.get_object(bucket: ENV['AWS_BUCKET'], key: file.key)
        expect(Digest::MD5.hexdigest(response.body.read)).to eq(checksum)
      end
    end

    context 'when the file exceeds the multipart upload threshold' do
      let(:file) do
        instance_spy(Scholarsphere::S3::UploadedFile,
                     source: path,
                     key: 'fakekey.txt',
                     size: uploader.multipart_threshold + 1_024)
      end

      it 'does NOT send the MD5 hash' do
        uploader.upload(file)
        expect(file).not_to have_received(:content_md5)
      end
    end

    # @note This tests the multipart brach of our upload method, but we still don't have a complete integration test
    # that verifies a multipart upload. Perhaps that's overkill?
    context 'when forcing multipart upload on a small file' do
      let(:uploader) { described_class.new(multipart_threshold: 1) }

      it 'adds the file to the S3 bucket' do
        expect do
          uploader.upload(file)
        end.to raise_error(ArgumentError, 'unable to multipart upload files smaller than 5MB')
      end
    end

    context 'when providing a passing md5 hash' do
      let(:file) { Scholarsphere::S3::UploadedFile.new(path, checksum: checksum) }

      it 'fails the upload with an error' do
        uploader.upload(file)
        response = uploader.client.get_object(bucket: ENV['AWS_BUCKET'], key: file.key)
        expect(Digest::MD5.hexdigest(response.body.read)).to eq(checksum)
      end
    end

    context 'when providing a failing md5 hash' do
      let(:file) { Scholarsphere::S3::UploadedFile.new(path, checksum: 'xxx') }

      it 'fails the upload with an error' do
        expect do
          uploader.upload(file)
        end.to raise_error(Aws::S3::Errors::BadDigest, 'The Content-Md5 you specified did not match what we received.')
      end
    end
  end
end

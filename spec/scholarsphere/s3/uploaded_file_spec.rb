# frozen_string_literal: true

require 'scholarsphere/s3'

RSpec.describe Scholarsphere::S3::UploadedFile do
  subject(:file) { described_class.new(source) }

  let(:source) { fixture_path('image.png') }

  its(:source) { is_expected.to eq(source) }
  its(:id) { is_expected.to match(/^[a-z0-9]{8}-[a-z0-9]{4}-[a-z0-9]{4}-[a-z0-9]{4}-[a-z0-9]{12}\.png$/) }
  its(:key) { is_expected.to eq("cache/#{file.id}") }

  describe '#content_md5' do
    context 'when the digest is calculated' do
      its(:content_md5) { is_expected.to eq(Digest::MD5.base64digest(source.read)) }
    end

    context 'when providing an existing md5 checksum' do
      subject(:file) { described_class.new(source, checksum: Digest::MD5.hexdigest(source.read)) }

      its(:content_md5) { is_expected.to eq(Digest::MD5.base64digest(source.read)) }
    end
  end

  describe '#to_shrine' do
    let(:shrine_hash) { file.to_shrine }

    it 'returns a hash for uploading to Shrine' do
      expect(shrine_hash[:id]).to eq(file.id)
      expect(shrine_hash[:storage]).to eq('cache')
      expect(shrine_hash[:metadata]).to eq(
        size: source.size,
        filename: 'image.png',
        mime_type: 'image/png'
      )
    end
  end
end

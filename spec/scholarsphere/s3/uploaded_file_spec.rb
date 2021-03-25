# frozen_string_literal: true

require 'scholarsphere/s3'

RSpec.describe Scholarsphere::S3::UploadedFile do
  subject(:file) { described_class.new(source: source) }

  let(:source) { fixture_path('image.png') }

  describe '#source' do
    subject { file.source }

    it { is_expected.to be_a(Pathname) }
  end

  describe '#to_param', :vcr do
    let(:params) { file.to_param }

    it 'returns a hash of required parameters' do
      expect(params[:id]).to match(/^[a-z0-9]{8}-[a-z0-9]{4}-[a-z0-9]{4}-[a-z0-9]{4}-[a-z0-9]{12}\.png$/)
      expect(params[:storage]).to eq('cache')
      expect(params[:metadata]).to eq(
        size: source.size,
        filename: 'image.png',
        mime_type: 'image/png'
      )
    end
  end

  describe '#content_md5' do
    context 'when the digest is calculated' do
      its(:content_md5) { is_expected.to eq(Digest::MD5.base64digest(source.read)) }
    end

    context 'when providing an existing md5 checksum' do
      subject(:file) { described_class.new(source: source, checksum: Digest::MD5.hexdigest(source.read)) }

      its(:content_md5) { is_expected.to eq(Digest::MD5.base64digest(source.read)) }
    end
  end

  describe '#presigned_url', :vcr do
    subject { file.presigned_url }

    it { is_expected.to include('cache') }
  end
end

# frozen_string_literal: true

RSpec.describe Scholarsphere::Client do
  it 'has a version number' do
    expect(Scholarsphere::Client::VERSION).not_to be nil
  end

  describe '.connection' do
    subject { described_class.connection }

    it { is_expected.to be_a(Faraday::Connection) }
    its(:headers) { is_expected.to include('Content-Type' => 'application/json') }

    context 'when verifying ssl' do
      before do
        described_class.reset
        ENV['SS_CLIENT_SSL'] = 'true'
      end

      its(:ssl) { is_expected.to be_verify }
    end

    context 'when NOT verifying ssl' do
      before do
        described_class.reset
        ENV['SS_CLIENT_SSL'] = 'false'
      end

      its(:ssl) { is_expected.not_to be_verify }
    end
  end
end

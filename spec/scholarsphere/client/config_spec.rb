# frozen_string_literal: true

RSpec.describe Scholarsphere::Client::Config do
  let(:config) { described_class.new(pathname) }

  describe '.load_config' do
    subject(:loaded_config) { config.load_config }

    context 'when there is no config file' do
      let(:pathname) { Pathname.new('missing_file.yml') }

      it { is_expected.to be_nil }
    end

    context 'when providing a config file' do
      let(:pathname) { fixture_path('scholarsphere-client.yml') }

      it do
        expect(loaded_config).to include(
          'SS4_ENDPOINT' => 'http://scholarsphere.endpoint',
          'SS_CLIENT_SSL' => 'false'
        )
      end
    end
  end
end

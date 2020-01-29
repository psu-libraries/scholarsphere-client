# frozen_string_literal: true

RSpec.describe Scholarsphere::Client::Ingest do
  let(:ingest) do
    described_class.new(
      metadata: { title: 'Sample Title' },
      files: [fixture_path('image.png'), fixture_path('ipsum.pdf')],
      depositor: 'agw13'
    )
  end

  describe '#publish' do
    it 'publishes new works into Scholarsphere' do
      response = ingest.publish
      expect(response.status).to eq(200)
      expect(JSON.parse(response.body)).to include('message' => 'Work was successfully created')
    end
  end
end

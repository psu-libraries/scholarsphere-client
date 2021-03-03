# frozen_string_literal: true

RSpec.describe Scholarsphere::Client::Ingest do
  let(:ingest) do
    described_class.new(
      metadata: metadata,
      files: files,
      depositor: depositor
    )
  end

  let(:metadata) do
    {
      title: title,
      creators_attributes: [creators]
    }
  end

  let(:depositor) do
    {
      psu_id: 'agw13',
      surname: 'Wead',
      given_name: 'Adam',
      email: 'agw13@psu.edu'
    }
  end

  let(:creators) do
    {
      display_name: 'Dan Coughlin',
      actor_attributes: {
        psu_id: 'dmc186',
        surname: 'Coughlin',
        given_name: 'Dan',
        email: 'dmc186@psu.edu'
      }
    }
  end

  describe '#publish', :vcr do
    context 'with an array of files' do
      let(:title) { 'Sample Title' }
      let(:files) { [fixture_path('image.png'), fixture_path('ipsum.pdf')] }

      it 'publishes new works into Scholarsphere' do
        response = ingest.publish
        expect(response.status).to eq(200)
        expect(JSON.parse(response.body)).to include('message' => 'Work was successfully created')
      end
    end

    context 'with an array of hashes specifying the deposit date' do
      let(:title) { 'Array of Hashes for Files' }
      let(:files) do
        [
          {
            file: fixture_path('image.png'),
            deposited_at: DateTime.parse('2012-05-16').iso8601
          }
        ]
      end

      it 'publishes the file with its additional metadata' do
        response = ingest.publish
        expect(response.status).to eq(200)
        expect(JSON.parse(response.body)).to include('message' => 'Work was successfully created')
      end
    end
  end
end

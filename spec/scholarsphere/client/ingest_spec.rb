# frozen_string_literal: true

RSpec.describe Scholarsphere::Client::Ingest do
  let(:publish) { true }
  let(:ingest) do
    described_class.new(
      metadata: metadata,
      files: files,
      depositor: 'jml8735',
      publish: publish
    )
  end

  let(:metadata) do
    {
      title: title,
      visibility: 'open',
      work_type: 'dataset',
      description: 'Sample description',
      published_date: '2020-10-11',
      rights: 'https://creativecommons.org/licenses/by/4.0/',
      creators: [
        { psu_id: 'dmc186' }
      ]
    }
  end

  describe '#create', :vcr do
    context 'with an array of files' do
      let(:title) { 'Sample Title' }
      let(:files) { [fixture_path('image.png'), fixture_path('ipsum.pdf')] }

      it 'publishes new works into Scholarsphere' do
        response = ingest.create
        expect(response.status).to eq(200)
        expect(JSON.parse(response.body)).to include('message' => 'Work was successfully created')
      end
    end

    context 'with publish set to false' do
      let(:title) { 'Another Title' }
      let(:files) { [fixture_path('image.png')] }
      let(:publish) { false }

      it 'creates new works without publishing them' do
        response = ingest.create
        expect(response.status).to eq(201)
        expect(JSON.parse(response.body)).to include('message' => 'Work was successfully created')
        expect(JSON.parse(response.body)).to include('edit_url')
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
        response = ingest.create
        expect(response.status).to eq(200)
        expect(JSON.parse(response.body)).to include('message' => 'Work was successfully created')
      end
    end
  end
end

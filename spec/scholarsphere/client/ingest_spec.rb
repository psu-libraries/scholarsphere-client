# frozen_string_literal: true

RSpec.describe Scholarsphere::Client::Ingest do
  let(:ingest) do
    described_class.new(
      metadata: metadata,
      files: files,
      depositor: depositor
    )
  end

  let(:depositor) do
    {
      email: 'jxd21@psu.edu',
      given_name: 'John',
      surname: 'Doe',
      psu_id: 'jxd21'
    }
  end

  let(:creator_alias) do
    {
      alias: 'John Doe',
      actor_attributes: {
        email: 'jxd21@psu.edu',
        given_name: 'John',
        surname: 'Doe',
        psu_id: 'jxd21'
      }
    }
  end

  describe '#publish' do
    context 'with an array of files' do
      let(:metadata) { { title: 'Sample Title', creator_aliases_attributes: [creator_alias] } }
      let(:files) { [fixture_path('image.png'), fixture_path('ipsum.pdf')] }

      it 'publishes new works into Scholarsphere' do
        response = ingest.publish
        expect(response.status).to eq(200)
        expect(JSON.parse(response.body)).to include('message' => 'Work was successfully created')
      end
    end

    context 'with an array of hashes specifying the deposit date' do
      let(:metadata) { { title: 'Array of Hashes for Files', creator_aliases_attributes: [creator_alias] } }
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

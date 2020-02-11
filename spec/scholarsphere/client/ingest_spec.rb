# frozen_string_literal: true

RSpec.describe Scholarsphere::Client::Ingest do
  let(:ingest) do
    described_class.new(
      metadata: { title: 'Sample Title', creator_aliases_attributes: [creator_alias] },
      files: files,
      depositor: 'jxd21'
    )
  end

  let(:creator_alias) do
    {
      alias: 'John Doe',
      creator_attributes: {
        email: 'jxd21@psu.edu',
        given_name: 'John',
        surname: 'Doe',
        psu_id: 'jxd21'
      }
    }
  end

  describe '#publish' do
    context 'with small files' do
      let(:files) { [fixture_path('image.png'), fixture_path('ipsum.pdf')] }

      it 'publishes new works into Scholarsphere' do
        response = ingest.publish
        expect(response.status).to eq(200)
        expect(JSON.parse(response.body)).to include('message' => 'Work was successfully created')
      end
    end
  end
end

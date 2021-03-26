# frozen_string_literal: true

RSpec.describe Scholarsphere::Client::Collection do
  let(:collection) do
    described_class.new(
      metadata: {
        title: 'Sample Title',
        creator_aliases_attributes: [creator_alias],
        description: 'Sample description'
      },
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

  describe '#create', :vcr do
    it 'creates a new collection in Scholarsphere' do
      response = collection.create
      expect(response.status).to eq(200)
      expect(JSON.parse(response.body)).to include('message' => 'Collection was successfully created')
    end
  end
end

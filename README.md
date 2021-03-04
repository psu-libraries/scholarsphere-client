# Scholarsphere::Client

Ruby client to update and create content in the Scholarsphere repository.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'scholarsphere-client'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install scholarsphere-client

## Usage

### Authentication

Obtain an api key, and save it to `config/scholarsphere-client.yml`

    SS4_ENDPOINT:  "http://scholarsphere/api/v1"
    SS_CLIENT_KEY: "[key]"

If you are using a testing instance, you'll need to disable ssl verification:
    
    SS_CLIENT_SSL: "false"

### Ingesting

To publish a work:

    metadata = {
      title: "My Awesome Work",
      creators_attributes: [
        {
          display_name: 'Dr. Pat Researcher',
          actor_attributes: {
            psu_id: 'pxr123',
            surname: 'Researcher',
            given_name: 'Pat',
            email: 'pxr123@psu.edu'
          }
        }
      ]
    }

    files = [ File.new('path/to/file') ]

    depositor = {
      psu_id: 'pxr123',
      surname: 'Researcher',
      given_name: 'Pat',
      email: 'pxr123@psu.edu'
    }

    ingest = Scholarsphere::Client::Ingest.new(
      metadata: metadata,
      files: files,
      depositor: depositor
    )

    response = ingest.publish

    puts response.body

    { 
      "message": "Work was successfully created",
      "url": "/resources/0797e99c-7d4f-4e05-8bf6-86aea1029a6a"
    }

## Documentation

You can read the [ruby docs](https://www.rubydoc.info/github/psu-stewardship/scholarsphere-client/main) for the latest features.

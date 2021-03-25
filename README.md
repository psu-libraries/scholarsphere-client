# Scholarsphere::Client

Ruby client to update and create content in the Scholarsphere repository.

## Installation

Add this line to your application's Gemfile:

    gem 'scholarsphere-client'

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

See the `sample.rb` file for an executable example.

To publish a work:

``` ruby
metadata = {
  work_type: 'dataset',
  visibility: 'open',
  rights: 'https://creativecommons.org/licenses/by/4.0/',
  title: 'Sample Title',
  description: "This is a sample work",
  published_date: '2010-01-01',
  creators: [
    { orcid: '0000-0000-1111-222X' },
    { psu_id: 'axb123' },
    { display_name: 'Dr. Unidentified Creator' }
  ]
}

files = [
  Pathname.new("/path/to/file1.txt"),
  Pathname.new("/path/to/file2.txt")
]

ingest = Scholarsphere::Client::Ingest.new(
  metadata: metadata,
  files: files,
  depositor: 'axb123'
)

response = ingest.publish

puts response.body
```

The json output should look like:
    
    { 
      "message": "Work was successfully created",
      "url": "/resources/0797e99c-7d4f-4e05-8bf6-86aea1029a6a"
    }

## Documentation

You can read the [ruby docs](https://www.rubydoc.info/github/psu-stewardship/scholarsphere-client/main) for the latest features.

## Testing

### Using an Existing Deployment

RSpec tests are run against saved API responses that are recorded using the VCR gem. If we want to run the test
suite against a live instance to see if our client works against a given deployment, update the endpoint in
`config/scholarsphere-client.yml` and run:

    DISABLE_VCR=true bundle exec rspec

### Updating VCR Files

Simply removing the existing VCR files should be enough to update all the responses. If no yaml file exists for a given
test, VCR will record a new one. Be sure to clean up files afterwards using `bin/clean-vcr-files` which will remove
unnecessary binary data from the responses:

    rm -Rf spec/fixtures/vcr_cassettes
    bundle exec rspec
    bin/clean-vcr-files

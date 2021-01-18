# frozen_string_literal: true

require 'vcr'

VCR.configure do |c|
  c.cassette_library_dir = 'spec/fixtures/vcr_cassettes'
  c.hook_into :webmock
  c.configure_rspec_metadata!
  c.allow_http_connections_when_no_cassette = true
  c.ignore_localhost = false
  c.debug_logger = File.open('vcr.log', 'w')
  c.default_cassette_options = { erb: true, update_content_length_header: true }
  c.preserve_exact_body_bytes do |http_message|
    http_message.body.encoding.name == 'ASCII-8BIT' ||
      !http_message.body.valid_encoding?
  end
end

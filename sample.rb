# frozen_string_literal: true

require 'bundler/inline'

gemfile do
  source 'https://rubygems.org'
  gem 'scholarsphere-client', '~> 0.2'
end

metadata = {
  work_type: 'dataset',
  visibility: 'open',
  rights: 'https://creativecommons.org/licenses/by/4.0/',
  title: 'Sample Title',
  description: 'This is a sample work',
  published_date: '2010-01-01',
  creators: [
    { orcid: '0000-0000-1111-222X' },
    { psu_id: 'axb123' },
    { display_name: 'Dr. Unidentified Creator' }
  ]
}

files = [
  Pathname.new('/path/to/file1.txt'),
  Pathname.new('/path/to/file2.txt')
]

ingest = Scholarsphere::Client::Ingest.new(
  metadata: metadata,
  files: files,
  depositor: 'axb123'
)

response = ingest.publish

puts response.body

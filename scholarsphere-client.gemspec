# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'scholarsphere/client/version'

Gem::Specification.new do |spec|
  spec.name          = 'scholarsphere-client'
  spec.version       = Scholarsphere::Client::VERSION
  spec.authors       = ['Adam Wead']
  spec.email         = ['amsterdamos@gmail.com']

  spec.summary       = 'Client to connect to Scholarpshere'
  spec.description   = 'Client software to create new content for the Scholarsphere repository at Penn State.'
  spec.homepage      = 'https://github.com/psu-libraries/scholarsphere-client'

  spec.metadata = {
    'homepage_uri' => spec.homepage,
    'source_code_uri' => spec.homepage,
    'documentation_uri' => 'https://www.rubydoc.info/github/psu-libraries/scholarsphere-client/main',
    'allowed_push_host' => 'https://rubygems.org',
    'rubygems_mfa_required' => 'true'
  }

  spec.required_ruby_version = '>= 3.4'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'aws-sdk-s3', '~> 1.49'
  spec.add_dependency 'faraday', '> 0.12'
  spec.add_dependency 'marcel', '~> 1.0'
  spec.add_dependency 'mutex_m', '~> 0.3'
end

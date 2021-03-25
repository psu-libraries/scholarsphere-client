# frozen_string_literal: true

require 'simplecov'
SimpleCov.start do
  add_filter('spec')
end

require 'bundler/setup'
require 'pry'
require 'scholarsphere/client'
require 'rspec/its'

Pathname.pwd.join('spec', 'support').children.each do |file|
  next if file.basename.to_s == 'vcr.rb' && ENV['DISABLE_VCR'] == 'true'

  require file
end

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

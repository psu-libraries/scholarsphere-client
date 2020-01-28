# frozen_string_literal: true

require 'psych'
require 'marcel'
require 'scholarsphere/s3'
require 'scholarsphere/client/version'

module Scholarsphere
  module Client
    class Error < StandardError; end

    Psych.safe_load(File.read('config/config.yml')).each do |key, value|
      ENV[key] ||= value
    end
  end
end

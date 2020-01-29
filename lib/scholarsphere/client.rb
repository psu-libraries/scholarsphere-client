# frozen_string_literal: true

require 'psych'
require 'marcel'
require 'faraday'
require 'scholarsphere/s3'
require 'scholarsphere/client/config'
require 'scholarsphere/client/ingest'
require 'scholarsphere/client/version'

module Scholarsphere
  module Client
    class Error < StandardError; end

    Config.load_defaults

    class << self
      def connection
        @connection ||= Faraday::Connection.new(
          url: ENV['SS4_ENDPOINT'],
          headers: { 'Content-Type' => 'application/json' }
        )
      end
    end
  end
end

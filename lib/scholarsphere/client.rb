# frozen_string_literal: true

require 'psych'
require 'marcel'
require 'faraday'
require 'scholarsphere/s3'
require 'scholarsphere/client/config'
require 'scholarsphere/client/ingest'
require 'scholarsphere/client/collection'
require 'scholarsphere/client/upload'
require 'scholarsphere/client/version'

module Scholarsphere
  module Client
    class Error < StandardError; end

    Config.load_defaults

    class << self
      # @return [Faraday::Connection] A cached connection to the Scholarsphere API with the provided credentials.
      def connection
        @connection ||= Faraday::Connection.new(
          url: ENV.fetch('SS4_ENDPOINT', nil),
          headers: {
            'Content-Type' => 'application/json',
            'X-API-KEY' => api_key
          },
          ssl: { verify: verify_ssl? }
        )
      end

      # @return [nil] Resets the client connection when needed.
      def reset
        @connection = nil
      end

      # @return [TrueClass, FalseClass] If set to 'false', Faraday will not verify the SSL certificate. This is mostly
      #   used for testing. Default is 'true'.
      def verify_ssl?
        ENV['SS_CLIENT_SSL'] != 'false'
      end

      # @return [String] Alphanumeric API key that grants access to the API.
      def api_key
        ENV.fetch('SS_CLIENT_KEY', nil)
      end
    end
  end
end

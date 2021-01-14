# frozen_string_literal: true

# @abstract Uploads a single file to an S3 instance using a presigned url. The url is generated with a call to
# Scholarsphere.

module Scholarsphere
  module S3
    class PresignedUploader
      attr_reader :file, :content_md5, :url

      # @param [UploadedFile] file
      def initialize(file:)
        @file = file
        @content_md5 = file.content_md5
        @url = URI.parse(file.presigned_url)
      end

      # @return [Faraday::Response]
      def upload
        connection.put do |req|
          req.body = file.source.read
          req.headers['Content-MD5'] = file.content_md5
        end
      end

      private

        def connection
          @connection ||= Faraday::Connection.new(
            url: url,
            ssl: { verify: Scholarsphere::Client.verify_ssl? }
          )
        end
    end
  end
end

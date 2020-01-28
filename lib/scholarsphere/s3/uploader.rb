# frozen_string_literal: true

module Scholarsphere
  module S3
    class Uploader < ::Aws::S3::FileUploader
      FIFTEEN_MEGABYTES = 15 * 1024 * 1024

      # @param [Hash] options
      # @option options [Client] :client
      # @option options [Integer] :multipart_threshold (15728640)
      def initialize(options = {})
        @options = options
        @client = options[:client] || ::Aws::S3::Client.new(client_defaults)
        @multipart_threshold = options[:multipart_threshold] || FIFTEEN_MEGABYTES
      end

      # @param [UploadedFile]
      # @param [Hash] of additional options
      # @options options [String] content_md5 a base64-encoded string representating the md5 checksum
      # @return [void]
      # @note The content_md5 hash cannot be used when doing a multipart upload.
      def upload(uploaded_file, options = {})
        options[:bucket] = ENV['AWS_BUCKET']
        options[:key] = uploaded_file.key
        if uploaded_file.size < multipart_threshold
          options[:content_md5] = uploaded_file.content_md5
        end
        super(uploaded_file.source, options)
      end

      private

        def client_defaults
          {
            endpoint: ENV['S3_ENDPOINT'],
            access_key_id: ENV['AWS_ACCESS_KEY_ID'],
            secret_access_key: ENV['AWS_SECRET_ACCESS_KEY'],
            force_path_style: true,
            region: ENV['AWS_REGION']
          }
        end
    end
  end
end

# frozen_string_literal: true

module Scholarsphere
  module S3
    class UploadedFile
      attr_reader :source, :checksum

      # @param [Pathname]
      # @option option [String] :checksum in md5 format
      def initialize(source, options = {})
        @source = source
        @checksum = options[:checksum]
      end

      # @return [Hash]
      # @note this can be passed to a controller for uploading the file to Shrine
      def to_shrine
        {
          id: id,
          storage: 'cache',
          metadata: metadata
        }
      end

      # @return [String]
      # @note This is the name of the file that will be stored in S3. It's using the same procedure that the
      # Uppy::S3Multipart gem is using.
      def id
        @id ||= "#{SecureRandom.uuid}#{source.extname}"
      end

      # @return [String]
      # @note Path of the file relative to the bucket
      def key
        "#{prefix}/#{id}"
      end

      # @return [String]
      # @note When sending the md5 checksum to verify the file's integrity, Amazon requires that the value of the
      # checksum be base64 encoded.
      # @example The equivalent operation in bash would be:
      #     openssl dgst -md5 -binary file.jpg | openssl enc -base64
      def content_md5
        @content_md5 ||= if checksum
                           Base64.encode64([checksum].pack('H*')).strip
                         else
                           Digest::MD5.base64digest(source.read)
                         end
      end

      def size
        source.size
      end

      def presigned_url
        body = JSON.parse(upload.body)
        return body['url'] if upload.success?

        raise Client::Error, body['message']
      end

      private

        def metadata
          {
            size: source.size,
            filename: source.basename.to_s,
            mime_type: Marcel::MimeType.for(source)
          }
        end

        def prefix
          ENV['SHRINE_CACHE_PREFIX'] || 'cache'
        end

        def upload
          @upload ||= Client::Upload.create(file: self)
        end
    end
  end
end

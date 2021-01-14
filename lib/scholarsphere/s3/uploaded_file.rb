# frozen_string_literal: true

module Scholarsphere
  module S3
    ##
    #
    # Represents a file on the client's file system that will be uploaded, but hasn't been yet. The object is
    # constructed using a pathname for the file, and if desired, a checksum. The checksum is not required, and if it is
    # not provided, the client will calculate one. Once initialized, the uploaded file object can be used by the client
    # to make additional calls to the application.
    #
    # ## Examples
    #
    # The most common use case would be:
    #
    #     pathname = Pathname.new('path/to/your/file')
    #     uploaded_file = UploadedFile.new(pathname)
    #
    # If the file is large, then calculating a checksum could be time-intensive. Providing one can avoid that. Or, if
    # you already have a checksum from a trusted source, you can pass that along for the client to use:
    #
    #     uploaded_file = UploadedFile.new(pathname, checksum: '[md5 checksum hash]')
    #
    class UploadedFile
      # @return [Pathname] The location of the file to be uploaded
      attr_reader :source

      # @param source [Pathname] The file to be uploaded
      # @param options [Hash]
      # @option options [String] :checksum The file's md5 checksum. If one is not provided, it will be calculated at
      #   upload
      def initialize(source, options = {})
        @source = source
        @checksum = options[:checksum]
      end

      # @return [Hash] Set of metadata needed by Shrine to upload the file
      # @note this can be passed to a controller for uploading the file to Shrine
      def to_shrine
        {
          id: id,
          storage: 'cache',
          metadata: metadata
        }
      end

      # @return [String] A unique, randomly-generated UUID
      # @note This serves as the name of the file in the S3 bucket. However, this original name of the file is kept as
      #   metadata within the application so that it can be downloaded.
      def id
        @id ||= "#{SecureRandom.uuid}#{source.extname}"
      end

      # @return [String] Path of the file relative to the bucket in S3
      def key
        "#{prefix}/#{id}"
      end

      # @return [String] The md5 checksum encoded in base64. If you provided a checksum at initialization, that one will
      #   be encoded, if not, a checksum will be calculated and then encoded.
      # @note When sending the checksum to verify the file's integrity, Amazon requires that the value be base64
      #   encoded.
      # @example The equivalent operation in bash would be:
      #     openssl dgst -md5 -binary file.jpg | openssl enc -base64
      def content_md5
        @content_md5 ||= if checksum
                           Base64.encode64([checksum].pack('H*')).strip
                         else
                           Digest::MD5.base64digest(source.read)
                         end
      end

      # @return [String] Size of the file in bytes
      def size
        source.size
      end

      private

        attr_reader :checksum

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
    end
  end
end

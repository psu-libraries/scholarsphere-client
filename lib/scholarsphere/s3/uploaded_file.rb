# frozen_string_literal: true

module Scholarsphere
  module S3
    ##
    #
    # Represents a file on the client's file system to be uploaded into Scholarsphere. The object is constructed using a
    # pathname for the file, and an optional checksum.  Once initialized, the object is used by the client to make
    # additional calls to the application, including uploading the file into S3, and adding the resulting uploaded file
    # to a work in Scholarsphere.
    #
    # ## Examples
    #
    # The most common use case would be:
    #
    #     pathname = Pathname.new('path/to/your/file')
    #     uploaded_file = UploadedFile.new(pathname)
    #
    # If the file is large, then calculating a checksum could be time-intensive. Providing one can avoid that, or, if
    # you already have a checksum from a trusted source, you can pass that along for the client to use:
    #
    #     uploaded_file = UploadedFile.new(pathname, checksum: '[md5 checksum hash]')
    #
    # ## Checksum Verification
    #
    # Checksums are always used. If you don't provide one, the client will calculate one for you and use it when
    # uploading the file, such as with S3::Uploader. AWS uses the provided checksum to verify the file's integrity, and
    # if that check fails, an exception is raised. This avoids the prospect that the file could be corrupted during its
    # transfer from the local client's filesystem into S3.
    #
    class UploadedFile
      # @return [Pathname] The file to be uploaded on the client's filesystem
      attr_reader :source

      # @param source [Pathname, File, IO, String] Object or path to the file
      # @param checksum [String] Optional md5 checksum of the file
      def initialize(source:, checksum: nil)
        @source = Pathname.new(source)
        @checksum = checksum
      end

      # @return [Hash] Parameters required to add the file to a work in Scholarsphere
      def to_param
        {
          id: upload.id,
          storage: upload.prefix,
          metadata: metadata
        }
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

      # @return [String] Pre-signed url used to upload the file into Scholarsphere's S3 instance.
      def presigned_url
        upload.url
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

        def upload
          @upload ||= Client::Upload.new(extname: source.extname, content_md5: content_md5)
        end
    end
  end
end

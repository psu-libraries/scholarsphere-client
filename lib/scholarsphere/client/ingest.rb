# frozen_string_literal: true

module Scholarsphere
  module Client
    class Ingest
      attr_reader :content, :metadata, :depositor, :permissions

      # @param metadata [Hash] Metadata attributes
      # @param files [Array<File,IO,Pathnme>,Hash] An array of File or IO objects, or a hash with a :file param
      # @param depositor [String] The access ID of the depositor
      # @param permissions [Hash] (optional) Additional permissions to apply to the resource
      def initialize(metadata:, files:, depositor:, permissions: {})
        @content = build_content_hash(files)
        @metadata = metadata
        @depositor = depositor
        @permissions = permissions
      end

      def publish
        upload_files
        connection.post do |req|
          req.url 'ingest'
          req.body = { metadata: metadata, content: content, depositor: depositor, permissions: permissions }.to_json
        end
      end

      private

        def build_content_hash(files)
          files.map do |file|
            if file.is_a?(Hash)
              file.merge(file: S3::UploadedFile.new(file.fetch(:file)))
            else
              { file: S3::UploadedFile.new(file) }
            end
          end
        end

        def upload_files
          content.map do |file_parameters|
            uploader.upload(file_parameters.fetch(:file))
            file_parameters[:file] = file_parameters[:file].to_shrine.to_json
          end
        end

        def uploader
          @uploader ||= S3::Uploader.new
        end

        def connection
          Scholarsphere::Client.connection
        end
    end
  end
end

# frozen_string_literal: true

module Scholarsphere
  module Client
    class Ingest
      attr_reader :files, :metadata, :depositor, :permissions

      # @param [Hash] metadata
      # @param [Array<File,IO,Pathnme>] files or anything with IO.read
      # @param [String] depositor
      # @param optional [Hash] permissions
      def initialize(metadata:, files:, depositor:, permissions: {})
        @files = files
        @metadata = metadata
        @depositor = depositor
        @permissions = permissions
      end

      def publish
        uploaded_files.map { |file| uploader.upload(file) }
        content = uploaded_files.map(&:to_shrine).map { |result| { file: result.to_json } }

        connection.post do |req|
          req.url 'ingest'
          req.body = { metadata: metadata, content: content, depositor: depositor, permissions: permissions }.to_json
        end
      end

      private

        def uploader
          @uploader = S3::Uploader.new
        end

        def uploaded_files
          @uploaded_files ||= files.map do |file|
            S3::UploadedFile.new(file)
          end
        end

        def connection
          Scholarsphere::Client.connection
        end
    end
  end
end

# frozen_string_literal: true

module Scholarsphere
  module Client
    ##
    #
    # Uploads a complete work into Scholarsphere. If successful, the work will be published and made
    # publicly available.
    #
    # ## Publishing a New Work
    #
    # The most common use case is uploading a single file with the required metadata:
    #
    #     ingest = Scholarsphere::Client::Ingest.new(
    #       metadata: metadata,
    #       files: files,
    #       depositor: 'abc123'
    #     )
    #     response = ingest.publish
    #
    # If the response is successful, the application returns 200 OK with JSON:
    #
    #     puts response.body
    #     {
    #       "message": "Work was successfully created",
    #       "url": "/resources/0797e99c-7d4f-4e05-8bf6-86aea1029a6a"
    #     }
    #
    # Other possible outcomes include:
    #
    #   * work was created, but not successfully published because of missing attributes (201 Created)
    #   * work could not be created due to insufficient parameters (422 Unprocessable Entity)
    #   * there was an error with the application (500 Internal Server Error)
    #
    # If possible, the response will include additional information about which errors occurred and which attributes are
    # required or are incorrect.
    #
    # ## Metadata
    #
    # A hash of descriptive metadata about the work. The minimal amount required in order to publish would be:
    #
    #     {
    #       title: "[descriptive title of the work]",
    #       creators_attributes: [
    #         {
    #           display_name: '[Penn State Person]',
    #           actor_attributes: {
    #             psu_id: 'abc123',
    #             surname: '[family name]',
    #             given_name: '[given name]',
    #             email: 'abc123@psu.edu'
    #           }
    #         }
    #       ]
    #     }
    #
    # For a complete listing of all the possible metadata values, see the OpenAPI docs for
    # Scholarsphere.
    #
    # ## Files
    #
    #     [
    #       Pathname.new('MyPaper.pdf'),
    #       Pathname.new('dataset.dat')
    #     ]
    #
    # One or more files are required in order for the work be published. The simplest method is an array of `IO`
    # objects. The client then uploads them into S3.
    #
    # *Note: All filenames must have an extension!*
    #
    # ## Depositor
    #
    # The depositor is identified by their Penn State access id, which must be active at the time of ingest.  In most
    # cases, the depositor will be the same person as the creator specified in the metadata; although, this is not
    # always the case.  The depositor may be someone who is uploading on behalf of the creator and is not affiliated
    # with the creation of the work. The depositor is *not* the client itself, either. The client is identified
    # separately via the API token.
    #
    #
    class Ingest
      attr_reader :content, :metadata, :depositor, :permissions

      # @param metadata [Hash] Metadata attributes
      # @param files [Array<File,IO,Pathnme>,Hash] An array of File or IO objects, or a hash with a :file param
      # @param depositor [String] access id of the depositor
      # @param permissions [Hash] (optional) Additional permissions to apply to the resource
      def initialize(metadata:, files:, depositor:, permissions: {})
        @content = build_content_hash(files)
        @metadata = metadata
        @depositor = depositor
        @permissions = permissions
      end

      # @return [Faraday::Response] The response from the Scholarsphere application.
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
              file.merge(file: S3::UploadedFile.new(source: file.fetch(:file)))
            else
              { file: S3::UploadedFile.new(source: file) }
            end
          end
        end

        def upload_files
          content.map do |file_parameters|
            S3::Uploader.new(file: file_parameters.fetch(:file)).upload
            file_parameters[:file] = file_parameters[:file].to_param.to_json
          end
        end

        def connection
          Scholarsphere::Client.connection
        end
    end
  end
end

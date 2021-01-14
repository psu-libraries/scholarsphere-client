# frozen_string_literal: true

module Scholarsphere
  module Client
    class Upload
      attr_reader :file

      # @param [UploadedFile] file
      def self.create(file:)
        Scholarsphere::Client.connection.post do |req|
          req.url 'uploads'
          req.body = { key: file.key }.to_json
        end
      end
    end
  end
end

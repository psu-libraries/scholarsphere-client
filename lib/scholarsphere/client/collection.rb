# frozen_string_literal: true

module Scholarsphere
  module Client
    class Collection
      attr_reader :metadata, :depositor, :permissions, :work_noids

      # @param [Hash] metadata
      # @param [String] depositor
      # @param optional [Hash] permissions
      # @param optional [Array] work_noids
      def initialize(metadata:, depositor:, permissions: {}, work_noids: [])
        @metadata = metadata
        @depositor = depositor
        @permissions = permissions
        @work_noids = work_noids
      end

      def create
        connection.post do |req|
          req.url 'collections'
          req.body = { metadata: metadata, depositor: depositor, permissions: {}, work_noids: work_noids }.to_json
        end
      end

      private

        def connection
          Scholarsphere::Client.connection
        end
    end
  end
end

# frozen_string_literal: true

module Scholarsphere
  module Client
    ##
    #
    # Loads the yaml configuration file for the client. The default location is `config/scholarsphere-client.yml` and
    # the client will load this file automatically whenever it is invoked.
    #
    # The configuration file should contain the endpoint of the Scholarsphere API and the API key.
    #
    # ## Required
    #
    #     SS4_ENDPOINT:   "https://scholarsphere.psu.edu/api/v1"
    #     SS_CLIENT_KEY:  "[key]"
    #
    # ## Optional
    #
    #     SS_CLIENT_SSL:  "false"
    #
    class Config
      # @private
      def self.load_defaults
        new.load_config
      end

      # @return [Pathname]
      attr_reader :file

      # @param [Pathname] file
      def initialize(file = Pathname.pwd.join('config', 'scholarsphere-client.yml'))
        @file = file
        load_config
      end

      # @private
      def load_config
        return unless file.exist?

        Psych.safe_load(file.read).each do |key, value|
          ENV[key] ||= value
        end
      end
    end
  end
end

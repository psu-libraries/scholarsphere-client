# frozen_string_literal: true

module Scholarsphere
  module Client
    class Config
      def self.load_defaults
        new.load_config
      end

      attr_reader :file

      def initialize(file = Pathname.pwd.join('config', 'scholarsphere-client.yml'))
        @file = file
        load_config
      end

      def load_config
        return unless file.exist?

        Psych.safe_load(file.read).each do |key, value|
          ENV[key] ||= value
        end
      end
    end
  end
end

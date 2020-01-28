# frozen_string_literal: true

require 'psych'
require 'marcel'
require 'scholarsphere/s3'
require 'scholarsphere/client/config'
require 'scholarsphere/client/version'

module Scholarsphere
  module Client
    class Error < StandardError; end

    Config.load_defaults
  end
end

# frozen_string_literal: true

require 'aws-sdk-s3'

module Scholarsphere
  module S3
    require_relative 's3/presigned_uploader'
    require_relative 's3/uploader'
    require_relative 's3/uploaded_file'
  end
end

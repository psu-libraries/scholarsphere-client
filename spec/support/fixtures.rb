# frozen_string_literal: true

module Fixtures
  def fixture_path(file)
    Pathname.pwd.join('spec', 'fixtures', file)
  end
end

RSpec.configure do |config|
  config.include Fixtures
end

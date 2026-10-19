# frozen_string_literal: true

spec = Gem::Specification.load("scholarsphere-client.gemspec")

spec.runtime_dependencies.each do |dependency|
  system("gem", "list", "--remote", "--exact", dependency.name)
end
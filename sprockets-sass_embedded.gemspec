# frozen_string_literal: true

require_relative "lib/sprockets/sass_embedded/version"

Gem::Specification.new do |spec|
  spec.required_ruby_version = ">= 2.7"

  spec.name          = "sprockets-sass_embedded"
  spec.version       = Sprockets::SassEmbedded::VERSION
  spec.authors       = ["Jason Garber"]
  spec.email         = ["jason@sixtwothree.org"]

  spec.summary       = "Process and compress Sass files using Sprockets 4 and Embedded Dart Sass."
  spec.description   = spec.summary
  spec.homepage      = "https://github.com/jgarber623/sprockets-sass_embedded"
  spec.license       = "MIT"

  spec.files         = Dir["lib/**/*"].reject { |f| File.directory?(f) }
  spec.files        += ["LICENSE", "CHANGELOG.md", "README.md"]
  spec.files        += ["sprockets-sass_embedded.gemspec"]

  spec.require_paths = ["lib"]

  spec.metadata = {
    "bug_tracker_uri"       => "#{spec.homepage}/issues",
    "changelog_uri"         => "#{spec.homepage}/blob/v#{spec.version}/CHANGELOG.md",
    "rubygems_mfa_required" => "true"
  }

  spec.add_runtime_dependency "sass-embedded", ">= 1.54.6"
  spec.add_runtime_dependency "sprockets", "~> 4.0"
end

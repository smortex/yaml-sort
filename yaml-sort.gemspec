# frozen_string_literal: true

require_relative "lib/yaml/sort/version"

Gem::Specification.new do |spec|
  spec.name = "yaml-sort"
  spec.version = Yaml::Sort::VERSION
  spec.authors = ["Romain Tartière"]
  spec.email = ["romain@blogreen.org"]

  spec.summary = "Sort lines in YAML files in a predictable order"
  spec.homepage = "https://github.com/smortex/yaml-sort"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.7.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "https://github.com/smortex/yaml-sort/blob/master/CHANGELOG.md"
  spec.metadata["rubygems_mfa_required"] = "true"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end - ["lib/yaml/sort/parser.ra"] + ["lib/yaml/sort/parser.rb"]
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "cri"

  spec.add_development_dependency "aruba"
  spec.add_development_dependency "racc"
end

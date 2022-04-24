# frozen_string_literal: true

require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)

require "rubocop/rake_task"

RuboCop::RakeTask.new

require "cucumber/rake/task"

Cucumber::Rake::Task.new

task default: %i[rubocop spec cucumber]

file "lib/yaml/sort/parser.rb": ["lib/yaml/sort/parser.ra"] do
  sh "racc --output-status --output-file=lib/yaml/sort/parser.rb lib/yaml/sort/parser.ra"
end

task spec: ["lib/yaml/sort/parser.rb"]
task cucumber: ["lib/yaml/sort/parser.rb"]

require "github_changelog_generator/task"
GitHubChangelogGenerator::RakeTask.new :changelog do |config|
  config.future_release = Yaml::Sort::VERSION
  config.header = <<~HEADER.chomp
    # Changelog
    All notable changes to this project will be documented in this file.
    The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/)
    and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).
  HEADER
  config.exclude_labels = %w[duplicate question invalid wontfix wont-fix skip-changelog ignore]
  config.user = "smortex"
  config.project = "yaml-sort"
  config.since_tag = "v1.0.0"
  config.issues = false
end

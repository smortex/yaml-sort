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

# frozen_string_literal: true

namespace :lint do
  desc "Check Hiera data content ordering"
  task :hiera_data_ordering do
    sh "yaml-sort", "--lint", *Dir.glob("data/**/*.yaml")
  end
end

desc "Reorder Hiera data in-place"
task :reorder_hiera_data do
  sh "yaml-sort", "--in-place", *Dir.glob("data/**/*.yaml")
end

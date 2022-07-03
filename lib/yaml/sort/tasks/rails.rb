# frozen_string_literal: true

namespace :test do
  desc "Check translations content ordering"
  task :translations_ordering do
    sh "yaml-sort", "--lint", *Dir.glob("config/locales/**/*.yml"), verbose: false
  end
end

desc "Reorder translations in-place"
task :reorder_translations do
  sh "yaml-sort", "--in-place", *Dir.glob("config/locales/**/*.yml"), verbose: false
end

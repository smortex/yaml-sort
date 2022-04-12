# frozen_string_literal: true

require "optparse"

require "cri"

module Yaml
  module Sort
    class Cli
      def initialize
        @parser = Yaml::Sort::Parser.new
      end

      def execute(argv) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
        options = {}
        OptionParser.new do |opts|
          opts.banner = "Usage: yaml-sort [options] [filename]"

          opts.on("-d", "--[no-]debug", "Run verbosely") do |d|
            options[:debug] = d
          end
        end.parse!
        io = argv.empty? ? $stdin.read : File.read(argv.shift)

        document = @parser.parse(io)
        document = document.sort

        if options[:debug]
          pp document
          exit
        end

        puts "---"
        puts document.to_s
      end
    end
  end
end

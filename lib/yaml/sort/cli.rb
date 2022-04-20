# frozen_string_literal: true

require "optparse"

require "cri"

module Yaml
  module Sort
    class Cli
      def initialize
        @parser = Yaml::Sort::Parser.new
      end

      def execute(argv) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
        options = {
          in_place: false,
          lint: false,
        }
        OptionParser.new do |opts|
          opts.banner = "Usage: yaml-sort [options] [filename]"

          opts.on("-d", "--[no-]debug", "Run verbosely") do |d|
            options[:debug] = d
          end
          opts.on("-i", "--in-place", "Update files in-place") do
            options[:in_place] = true
          end
          opts.on("-l", "--lint", "Ensure files content is sorted as expected") do
            options[:lint] = true
          end
        end.parse!

        if !options[:in_place] && !options[:lint] && argv.count > 1
          warn "Sorting multiple YAML document to stdout does not make sense"
          return 1
        end

        if options[:in_place] && argv.count < 1
          warn "Cannot sort in-place when reading from stdin"
          return 1
        end

        @exit_code = 0

        if argv.empty?
          process_document(nil, options)
        else
          argv.each do |filename|
            process_document(filename, options)
          end
        end

        @exit_code
      end

      def process_document(filename, options)
        yaml = read_document(filename)
        sorted_yaml = sort_yaml(yaml)
        write_output(yaml, sorted_yaml, filename, options)
      end

      def read_document(filename)
        if filename
          File.read(filename)
        else
          $stdin.read
        end
      end

      def sort_yaml(yaml)
        document = @parser.parse(yaml)
        document = document.sort
        "---\n#{document}\n"
      end

      def write_output(yaml, sorted_yaml, filename, options)
        if options[:in_place]
          File.write(filename, sorted_yaml)
        elsif options[:lint]
          if yaml != sorted_yaml
            warn "#{filename || "<stdin>"} is not sorted as expected"
            @exit_code = 1
          end
        else
          puts sorted_yaml
        end
      end
    end
  end
end

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
        options = {
          in_place: false,
        }
        OptionParser.new do |opts|
          opts.banner = "Usage: yaml-sort [options] [filename]"

          opts.on("-d", "--[no-]debug", "Run verbosely") do |d|
            options[:debug] = d
          end
          opts.on("-i", "--in-place", "Update files in-place") do
            options[:in_place] = true
          end
        end.parse!

        if !options[:in_place] && argv.count > 1
          warn "Sorting multiple YAML document to stdout does not make sense"
          exit 1
        end

        if options[:in_place] && argv.count < 1
          warn "Cannot sort in-place when reading from stdin"
          exit 1
        end

        if argv.empty?
          process_document(nil, options)
        else
          argv.each do |filename|
            process_document(filename, options)
          end
        end
      end

      def process_document(filename, options)
        yaml = read_document(filename)
        yaml = sort_yaml(yaml)
        write_output(yaml, filename, options)
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

      def write_output(yaml, filename, options)
        if options[:in_place]
          File.write(filename, yaml)
        else
          puts yaml
        end
      end
    end
  end
end

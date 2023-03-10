# frozen_string_literal: true

require "optparse"

require "cri"
require "tempfile"

module Yaml
  module Sort
    class Cli
      def initialize
        @parser = Yaml::Sort::Parser.new
      end

      def execute(argv, kernel = Kernel) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
        options = {
          in_place: false,
          lint: false,
        }
        OptionParser.new do |opts|
          opts.banner = "Usage: yaml-sort [options] [filename]"

          opts.on("-i", "--in-place", "Update files in-place") do
            options[:in_place] = true
          end
          opts.on("-l", "--lint", "Ensure files content is sorted as expected") do
            options[:lint] = true
          end
        end.parse!(argv)

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

        kernel.exit(@exit_code)
      end

      def process_document(filename, options)
        yaml = read_document(filename)
        sorted_yaml = sort_yaml(yaml, filename)
        write_output(yaml, sorted_yaml, filename, options)
      rescue Racc::ParseError => e
        warn(e.message)
        @exit_code = 1
      end

      def read_document(filename)
        if filename
          File.read(filename)
        else
          $stdin.read
        end
      end

      def sort_yaml(yaml, filename)
        document = @parser.parse(yaml, filename: filename)
        @parser.sort_anchors!
        document = document.sort
        "---\n#{document}\n"
      end

      def write_output(yaml, sorted_yaml, filename, options)
        if options[:in_place]
          File.write(filename, sorted_yaml)
        elsif options[:lint]
          if yaml != sorted_yaml
            show_diff(filename, yaml, sorted_yaml)
            @exit_code = 1
          end
        else
          puts sorted_yaml
        end
      end

      def show_diff(filename, actual, expected)
        filename ||= "<stdin>"

        a = Tempfile.new
        a.write(actual)
        a.close

        b = Tempfile.new
        b.write(expected)
        b.close

        warn "diff #{File.join("a", filename)} #{File.join("b", filename)}"
        warn `diff -u --label "#{File.join("a", filename)}" #{a.path} --label "#{File.join("b", filename)}" #{b.path}`
      end
    end
  end
end

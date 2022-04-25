# frozen_string_literal: true

module Yaml
  module Sort
    class Dictionary < Value
      attr_reader :items

      def initialize(items = [])
        super()
        @items = items
      end

      def add_item(key, value)
        @items << [key, value]
      end

      def self.create(key, value)
        dict = Dictionary.new
        dict.add_item(key, value)
        dict
      end

      def to_s(skip_first_indent: false)
        n = -1
        super + items.map do |k, v|
          n += 1
          case v
          when List, Dictionary
            "#{k.to_s(skip_first_indent: skip_first_indent && n.zero?)}\n#{v}"
          when Scalar
            "#{k.to_s(skip_first_indent: skip_first_indent && n.zero?)} #{v}"
          end
        end.join("\n")
      end

      def sort
        Dictionary.new(items.map { |a| [a[0], a[1].sort] }.sort do |a, b|
          if a[0].value == "lookup_options:"
            -1
          elsif b[0].value == "lookup_options:"
            1
          else
            a[0] <=> b[0]
          end
        end)
      end
    end
  end
end

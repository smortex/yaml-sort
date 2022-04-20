# frozen_string_literal: true

module Yaml
  module Sort
    class List < Value
      attr_reader :items

      def initialize(items = [])
        super()
        @items = items
      end

      def add_item(dash, value)
        @items << [dash, value]
      end

      def self.create(dash, value)
        list = List.new
        list.add_item(dash, value)
        list
      end

      def to_s
        super + items.map do |item|
          "#{item[0]}#{item[1]}"
        end.join("\n")
      end

      def sort
        List.new(items.sort { |a, b| a[1] <=> b[1] })
      rescue ArgumentError
        # Non-comparable items
        self
      end
    end
  end
end

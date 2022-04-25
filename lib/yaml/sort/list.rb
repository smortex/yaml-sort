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
          "#{item[0]}#{item[1].to_s(skip_first_indent: true)}"
        end.join("\n")
      end

      def sort
        # TODO: Add an option to sort scalar values
        List.new(items.map { |i| [i[0], i[1].sort] })
      end
    end
  end
end

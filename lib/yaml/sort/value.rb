# frozen_string_literal: true

module Yaml
  module Sort
    class Value
      def initialize
        @comment = []
      end

      def to_s(*)
        comments
      end

      def comments
        @comment.join
      end

      def sort
        self
      end
    end
  end
end

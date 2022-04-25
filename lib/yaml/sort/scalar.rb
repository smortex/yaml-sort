# frozen_string_literal: true

module Yaml
  module Sort
    class Scalar < Value
      attr_reader :value, :indent

      def initialize(value)
        super()
        @comment = value[:comment] || []
        @value = value[:value]
        @indent = value[:indent] || ""
      end

      def <=>(other)
        if other.is_a?(Scalar)
          value <=> other.value
        else
          0
        end
      end

      def to_s(skip_first_indent: false)
        if skip_first_indent
          super + value
        else
          super + indent + value
        end
      end
    end
  end
end

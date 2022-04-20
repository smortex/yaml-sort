# frozen_string_literal: true

module Yaml
  module Sort
    class Scalar < Value
      attr_reader :value

      def initialize(value)
        super()
        @comment = value[:comment] || []
        @value = value[:value]
      end

      def <=>(other)
        if other.is_a?(Scalar)
          value <=> other.value
        else
          0
        end
      end

      def to_s
        super + value
      end
    end
  end
end

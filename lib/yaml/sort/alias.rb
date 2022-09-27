# frozen_string_literal: true

module Yaml
  module Sort
    class Alias < Value
      attr_reader :name

      def initialize(anchors, name)
        super()
        @anchors = anchors
        @name = name[:value]
      end

      def value?
        @anchors[@name]
      end

      def delete_value
        @anchors.delete(@name)
      end

      def to_s(*)
        if (s = @anchors.delete(@name))
          separator = case s
                      when List, Dictionary then "\n"
                      else " "
                      end
          "&#{name}#{separator}#{s}"
        else
          "*#{name}"
        end
      end

      def <=>(_other)
        0
      end
    end
  end
end

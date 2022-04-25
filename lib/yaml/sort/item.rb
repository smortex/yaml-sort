# frozen_string_literal: true

require_relative "scalar"

module Yaml
  module Sort
    class Item < Scalar
      def to_s(*)
        comments + value
      end
    end
  end
end

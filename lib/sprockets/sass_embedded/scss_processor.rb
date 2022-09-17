# frozen_string_literal: true

module Sprockets
  module SassEmbedded
    class ScssProcessor < SassProcessor
      # @return [Symbol]
      def self.syntax
        :scss
      end
    end
  end
end

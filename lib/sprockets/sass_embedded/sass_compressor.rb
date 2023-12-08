# frozen_string_literal: true

module Sprockets
  module SassEmbedded
    # Sass CSS minifier.
    #
    # @example Using the default options.
    #
    #   environment.register_bundle_processor "text/css",
    #     Sprockets::SassEmbedded::SassCompressor
    #
    # @example Passing options to the SassEmbedded compiler.
    #
    #   environment.register_bundle_processor "text/css",
    #     Sprockets::SassEmbedded::SassCompressor.new({ ... })
    #
    class SassCompressor
      VERSION = "1"

      private_constant :VERSION

      # @return [String]
      def self.cache_key
        instance.cache_key
      end

      # @param input [Hash]
      # @return [Hash{Symbol => String}]
      def self.call(input)
        instance.call(input)
      end

      # @return [Sprockets::SassEmbedded::SassCompressor]
      def self.instance
        @instance ||= new
      end

      # @param options [Hash]
      def initialize(**options)
        @options = {
          source_map: true,
          style: :compressed,
          syntax: :css
        }.merge(options).freeze
      end

      # @return [String]
      def cache_key
        @cache_key ||=
          [
            self.class.name,
            Autoload::SassEmbedded::Embedded::VERSION,
            VERSION,
            DigestUtils.digest(@options)
          ].join(":")
      end

      # @param input [Hash]
      # @return [Hash{Symbol => String}]
      def call(input)
        result = Autoload::SassEmbedded.compile_string(
          input[:data],
          **@options.merge(url: URIUtils.build_asset_uri(input[:filename]))
        )

        css = result.css

        map = SourceMapUtils.combine_source_maps(
          input[:metadata][:map],
          SourceMapUtils.format_source_map(JSON.parse(result.source_map), input)
        )

        { data: css, map: map }
      end
    end
  end
end

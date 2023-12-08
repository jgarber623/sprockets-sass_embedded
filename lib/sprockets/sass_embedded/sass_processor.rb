# frozen_string_literal: true

module Sprockets
  module SassEmbedded
    class SassProcessor
      # @see https://sass-lang.com/documentation/js-api/interfaces/Options#functions
      class DartSassFunctionsHash
        # @param functions [Module]
        # @param options [Hash{Symbol => Hash}]
        def initialize(functions, options)
          @functions = functions

          instance.define_singleton_method(:options, -> { options })
        end

        # @return [Hash{String => Proc}]
        def to_hash
          @functions
            .public_instance_methods
            .each_with_object({}) do |symbol, obj|
              parameters = instance.method(symbol)
                                   .parameters
                                   .filter_map { |parameter| "$#{parameter.last}" if parameter.first == :req }

              obj["#{symbol}(#{parameters.join(', ')})"] = ->(args) { instance.public_send(symbol, *args) }
            end
        end

        alias_method :to_h, :to_hash

        private

        def instance
          @instance ||= Class.new.extend(@functions)
        end
      end

      private_constant :DartSassFunctionsHash

      VERSION = "1"

      private_constant :VERSION

      # @return [String]
      def self.cache_key
        instance.cache_key
      end

      def self.call(input)
        instance.call(input)
      end

      # @return [Sprockets::SassEmbedded::SassProcessor]
      def self.instance
        @instance ||= new
      end

      # @return [Symbol]
      def self.syntax
        :indented
      end

      # Public: Initialize template with custom options.
      #
      # options - Hash
      # cache_version - String custom cache version. Used to force a cache
      #                 change after code changes are made to Sass Functions.
      #
      def initialize(cache_version: nil, functions: nil, sass_config: {}, **_options)
        @cache_version = cache_version
        @sass_config = sass_config

        @functions =
          Module.new do
            include Functions
            include functions if functions
            class_eval(&block) if block_given?
          end
      end

      # @return [String]
      def cache_key
        @cache_key ||=
          [
            self.class.name,
            VERSION,
            Autoload::SassEmbedded::Embedded::VERSION,
            @cache_version
          ].join(":")
      end

      # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
      def call(input)
        context = input[:environment].context_class.new(input)

        options = merge_options(
          functions: DartSassFunctionsHash.new(
            @functions,
            sprockets: {
              context: context,
              dependencies: context.metadata[:dependencies],
              environment: input[:environment]
            }
          ).to_h,
          load_paths: context.environment.paths,
          source_map: true,
          syntax: self.class.syntax,
          url: URIUtils.build_asset_uri(input[:filename])
        )

        result = Autoload::SassEmbedded.compile_string(input[:data], **options)

        css = result.css

        map = SourceMapUtils.combine_source_maps(
          input[:metadata][:map],
          SourceMapUtils.format_source_map(JSON.parse(result.source_map), input)
        )

        sass_dependencies = Set.new

        result.loaded_urls.each do |url|
          scheme, _host, path, _query = URIUtils.split_file_uri(url)

          next unless scheme == "file"

          sass_dependencies << path
          context.metadata[:dependencies] << URIUtils.build_file_digest_uri(path)
        end

        context.metadata.merge(data: css, map: map, sass_dependencies: sass_dependencies)
      end
      # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

      private

      def merge_options(options)
        defaults = @sass_config.dup

        if (load_paths = defaults.delete(:load_paths))
          options[:load_paths] += load_paths
        end

        options.merge!(defaults)
      end

      # Functions injected into Sass context during Sprockets evaluation.
      #
      # This module may be extended to add global functionality to all Sprockets
      # Sass environments. Scoping your functions to just your environment is
      # preferred.
      #
      # @example
      #
      #   module Sprockets::SassProcessor::Functions
      #     def asset_path(path, options = {})
      #     end
      #   end
      #
      module Functions
        # Generate a URL for asset path.
        #
        # @param path [Sass::Script::String]
        # @param options [Hash]
        # @return [SassEmbedded::Value::String]
        def asset_path(path, **options)
          path = path.text

          path, _, query, fragment = URI.split(path)[5..8]
          path     = sprockets_context.asset_path(path, options)
          query    = "?#{query}" if query
          fragment = "##{fragment}" if fragment

          Autoload::SassEmbedded::Value::String.new("#{path}#{query}#{fragment}", quoted: true)
        end

        # Generate an asset +url()+ link.
        #
        # @param path [Sass::Script::String]
        # @return [SassEmbedded::Value::String]
        def asset_url(path, **options)
          Autoload::SassEmbedded::Value::String.new("url(#{asset_path(path, options).text})", quoted: false)
        end

        # Generate a URL for image path.
        #
        # @param path [Sass::Script::String]
        # @return [SassEmbedded::Value::String]
        def image_path(path)
          asset_path(path, type: :image)
        end

        # Generate an image +url()+ link.
        #
        # @param path [Sass::Script::String]
        # @return [SassEmbedded::Value::String]
        def image_url(path)
          asset_url(path, type: :image)
        end

        # Generate a URL for video path.
        #
        # @param path [Sass::Script::String]
        # @return [SassEmbedded::Value::String]
        def video_path(path)
          asset_path(path, type: :video)
        end

        # Generate a video +url()+ link.
        #
        # @param path [Sass::Script::String]
        # @return [SassEmbedded::Value::String]
        def video_url(path)
          asset_url(path, type: :video)
        end

        # Generate a URL for audio path.
        #
        # @param path [Sass::Script::String]
        # @return [SassEmbedded::Value::String]
        def audio_path(path)
          asset_path(path, type: :audio)
        end

        # Generate an audio +url()+ link.
        #
        # @param path [Sass::Script::String]
        # @return [SassEmbedded::Value::String]
        def audio_url(path)
          asset_url(path, type: :audio)
        end

        # Generate a URL for font path.
        #
        # @param path [Sass::Script::String]
        # @return [SassEmbedded::Value::String]
        def font_path(path)
          asset_path(path, type: :font)
        end

        # Generate a font +url()+ link.
        #
        # @param path [Sass::Script::String]
        # @return [SassEmbedded::Value::String]
        def font_url(path)
          asset_url(path, type: :font)
        end

        # Generate a URL for JavaScript path.
        #
        # @param path [Sass::Script::String]
        # @return [SassEmbedded::Value::String]
        def javascript_path(path)
          asset_path(path, type: :javascript)
        end

        # Generate a JavaScript +url()+ link.
        #
        # @param path [Sass::Script::String]
        # @return [SassEmbedded::Value::String]
        def javascript_url(path)
          asset_url(path, type: :javascript)
        end

        # Generate a URL for stylesheet path.
        #
        # @param path [Sass::Script::String]
        # @return [SassEmbedded::Value::String]
        def stylesheet_path(path)
          asset_path(path, type: :stylesheet)
        end

        # Generate a stylesheet +url()+ link.
        #
        # @param path [Sass::Script::String]
        # @return [SassEmbedded::Value::String]
        def stylesheet_url(path)
          asset_url(path, type: :stylesheet)
        end

        # Generate a +data:+ URI for asset path.
        #
        # @param path [Sass::Script::String]
        # @return [SassEmbedded::Value::String]
        def asset_data_uri(path)
          url = sprockets_context.asset_data_uri(path.text)
          Autoload::SassEmbedded::Value::String.new(url)
        end

        # Genearte a +data:+ +url()+ link.
        #
        # @param path [Sass::Script::String]
        # @return [SassEmbedded::Value::String]
        def asset_data_url(path)
          Autoload::SassEmbedded::Value::String.new("url(#{asset_data_uri(path)})", quoted: false)
        end

        protected

        # @deprecated Use #sprockets_environment or #sprockets_dependencies
        # instead.
        #
        # @return [Sprockets::Context]
        def sprockets_context
          options[:sprockets][:context]
        end

        # A mutatable set of dependencies.
        #
        # @return [Set]
        def sprockets_dependencies
          options[:sprockets][:dependencies]
        end

        # The Environment.
        #
        # @return [Sprockets::Environment]
        def sprockets_environment
          options[:sprockets][:environment]
        end
      end
    end
  end
end

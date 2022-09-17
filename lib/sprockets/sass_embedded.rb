# frozen_string_literal: true

require 'sass-embedded'
require 'sprockets'

require_relative 'sass_embedded/sass_compressor'
require_relative 'sass_embedded/sass_processor'
require_relative 'sass_embedded/scss_processor'

module Sprockets
  module Autoload
    SassEmbedded = ::Sass
  end

  register_transformer 'text/sass', 'text/css', SassEmbedded::SassProcessor
  register_transformer 'text/scss', 'text/css', SassEmbedded::ScssProcessor

  register_compressor 'text/css', :sass_embedded, SassEmbedded::SassCompressor
end

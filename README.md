# sprockets-sass_embedded

**A Ruby gem for processing and compressing [Sass](https://sass-lang.com) files using [Sprockets 4](https://github.com/rails/sprockets) and [Embedded Dart Sass](https://github.com/ntkme/sass-embedded-host-ruby).**

[![Gem](https://img.shields.io/gem/v/sprockets-sass_embedded.svg?logo=rubygems&style=for-the-badge)](https://rubygems.org/gems/sprockets-sass_embedded)
[![Downloads](https://img.shields.io/gem/dt/sprockets-sass_embedded.svg?logo=rubygems&style=for-the-badge)](https://rubygems.org/gems/sprockets-sass_embedded)
[![Build](https://img.shields.io/github/actions/workflow/status/jgarber623/sprockets-sass_embedded/ci.yml?branch=main&logo=github&style=for-the-badge)](https://github.com/jgarber623/sprockets-sass_embedded/actions/workflows/ci.yml)

## Getting Started

Before installing and using sprockets-sass_embedded, you'll want to have [Ruby](https://www.ruby-lang.org) 2.7 (or newer) installed. Using a Ruby version managment tool like [rbenv](https://github.com/rbenv/rbenv), [chruby](https://github.com/postmodern/chruby), or [rvm](https://github.com/rvm/rvm) is recommended.

sprockets-sass_embedded is developed using Ruby 2.7.8 and is tested against additional Ruby versions using [GitHub Actions](https://github.com/jgarber623/sprockets-sass_embedded/actions).

## Installation

Add sprockets-sass_embedded to your project's `Gemfile` and run `bundle install`:

```ruby
source "https://rubygems.org"

gem "sprockets-sass_embedded"
```

## Usage

sprockets-sass_embedded works with projects leveraging Sprockets 4 for asset processing. With minimal configuration changes, [Ruby on Rails](https://rubyonrails.org), [Sinatra](https://sinatrarb.com), and [Roda](http://roda.jeremyevans.net) applications can take advantage of the features in recent versions of Dart Sass. sprockets-sass_embedded uses [Natsuki](https://github.com/ntkme)'s [sass-embedded](https://github.com/ntkme/sass-embedded-host-ruby) gem whose platform-specific releases closely track (and match version-for-version) the official [dart-sass](https://github.com/sass/dart-sass) project's releases.

The examples below assume a Sass file named `application.scss` located in the assets path (e.g. `app/assets/stylesheets/application.scss`) appropriate for your app's framework. Asset paths are highly configurable, so the location of your asset files may vary.

### Ruby on Rails

With sprockets-sass_embedded added to your project's Gemfile and installed, set `config.assets.css_compressor = :sass_embedded` in your application's environment configuration. See the [Configuring Assets](https://guides.rubyonrails.org/configuring.html#configuring-assets) guide for additional details.

### Sinatra

In Sinatra applications, sprockets-sass_embedded can work in conjunction with the [sinatra-asset-pipeline](https://rubygems.org/gems/sinatra-asset-pipeline) gem. Using [sinatra-asset-pipeline's defaults](https://github.com/kalasjocke/sinatra-asset-pipeline/blob/master/lib/sinatra/asset_pipeline.rb#L7-L18), a sample `app.rb` file may look like:

```ruby
class App < Sinatra::Base
  set :assets_precompile, %w(application.css)

  set :assets_css_compressor, :sass_embedded

  register Sinatra::AssetPipeline

  get "/" do
    "Hello, world!"
  end
end
```

### Roda

Similar to Sinatra, Roda applications may be configured to use sprockets-sass_embedded alongside the [roda-sprockets](https://rubygems.org/gems/roda-sprockets) gem. A sample `config.ru` file might look like:

```ruby
class App < Roda
  plugin :render

  plugin :sprockets,
         css_compressor: :sass_embedded,
         debug: false,
         precompile: %w[application.css]

  route do |r|
    r.sprockets unless opts[:environment] == "production"

    r.root do
      render :index
    end
  end
end

run App.freeze.app
```

## Asset Helpers

sprockets-sass-embedded includes a number of familiar helpers (e.g. `image_path`, `image_url`, `font_path`, `font_url`) that generate asset paths for use in your application. See [the `Functions` module](https://github.com/jgarber623/sprockets-sass_embedded/blob/main/lib/sprockets/sass_embedded/sass_processor.rb#L144-L318) in `lib/sprockets/sass_embedded/sass_processor.rb` for the available helpers.

```scss
@font-face {
  font-family: "Hot Rush";
  src: font_url("hot-rush.woff2") format("woff2"),
       font_url("hot-rush.woff") format("woff");
}

html {
  background: image_url("vaporwave.png") repeat 50% 50%;
  font-family: "Times New Roman"
}

h1 {
  font-family: "Hot Rush";
}
```

## Acknowledgments

sprockets-sass_embedded implements [Natsuki](https://github.com/ntkme)'s work from [rails/sprockets#737](https://github.com/rails/sprockets/pull/737) and wouldn't exist if not for their work bringing Dart Sass to Sprockets-enabled Ruby projects. Sprockets' internal workings are _fairly_ complicated, so the [Extending Sprockets guide](https://github.com/rails/sprockets/blob/main/guides/extending_sprockets.md) was also helpful.

sprockets-sass_embedded is written and maintained by [Jason Garber](https://sixtwothree.org).

## License

sprockets-sass_embedded is freely available under the [MIT License](https://opensource.org/licenses/MIT). Use it, learn from it, fork it, improve it, change it, tailor it to your needs.

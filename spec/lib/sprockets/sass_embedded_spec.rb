# frozen_string_literal: true

RSpec.describe Sprockets::SassEmbedded do
  subject(:env) { Sprockets::Environment.new }

  let(:css) do
    <<~CSS.chomp
      html {
        font-size: 1rem;
      }

      body {
        background: #ccc;
      }
      body a {
        text-decoration: underline;
      }

    CSS
  end

  before do
    env.append_path File.expand_path("../../support/fixtures", __dir__)
  end

  it "processes *.sass files" do
    expect(env["sass/styles.css"].to_s).to eq(css)
  end

  it "processes *.scss files" do
    expect(env["scss/styles.css"].to_s).to eq(css)
  end
end

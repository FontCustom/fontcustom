require "spec_helper"
require "fontcustom/cli"

describe Fontcustom::CLI do
  context "#compile" do
    it "should generate fonts and templates (integration)", :integration => true do
      live_test do |testdir|
        Fontcustom::CLI.start ["compile", "vectors", "--quiet"]
        manifest = File.join testdir, ".fontcustom-manifest.json"
        preview = File.join testdir, "fontcustom", "fontcustom-preview.html"

        expect(Dir.glob(File.join(testdir, "fontcustom", "fontcustom_*\.{ttf,svg,woff,eot}")).length).to eq(4)
        expect(File.read(manifest)).to match(/"fonts":.+fontcustom\/fontcustom_.+\.ttf"/m)
        expect(File.exists?(preview)).to be_truthy
      end
    end

    it "should generate fonts and templates according to passed options (integration)", :integration => true do
      live_test do |testdir|
        Fontcustom::CLI.start ["compile", "vectors", "--font-name", "example", "--preprocessor-path", "../foo/bar", "--templates", "css", "scss-rails", "preview", "--no-hash", "--base64", "--quiet"]
        manifest = File.join testdir, ".fontcustom-manifest.json"
        css = Dir.glob(File.join("example", "*.scss")).first

        expect(File.read(manifest)).to match(/"fonts":.+example\/example\.ttf"/m)
        expect(File.read(css)).to match("x-font-woff")
        expect(File.read(css)).to match("../foo/bar/")
      end
    end

    context 'single quotes' do
      it "should generate fonts and templates with single quotes" do
        live_test do |testdir|
          Fontcustom::CLI.start ["compile", "vectors", "--templates", "preview", "css", "scss-rails", "--single-quotes"]
          preview = File.join testdir, "fontcustom", "fontcustom-preview.html"

          expect(Dir.glob(File.join(testdir, "fontcustom", "fontcustom_*\.{ttf,svg,woff,eot}")).length).to eq(4)
          expect(File.exists?(preview)).to be_truthy

          generated_css = File.read Dir.glob(File.join(testdir, "fontcustom", "*.css")).first
          expect(generated_css.scan('"').count).to be 0

          generated_scss = File.read Dir.glob(File.join(testdir, "fontcustom", "*.scss")).first
          expect(generated_scss.scan('"').count).to be 0
        end
      end
    end

    context 'css3' do
      it "should generate css3 stylesheets" do
        live_test do |testdir|
          Fontcustom::CLI.start ["compile", "vectors", "--templates", "preview", "css", "scss-rails", "--css3"]
          preview = File.join testdir, "fontcustom", "fontcustom-preview.html"

          expect(Dir.glob(File.join(testdir, "fontcustom", "fontcustom_*\.{ttf,svg,woff,eot}")).length).to eq(4)
          expect(File.exists?(preview)).to be_truthy

          generated_css = File.read Dir.glob(File.join(testdir, "fontcustom", "*.css")).first
          expect(generated_css.scan(/[^\:]\:before/).count).to be 0

          generated_scss = File.read Dir.glob(File.join(testdir, "fontcustom", "*.scss")).first
          expect(generated_scss.scan(/[^\:]\:before/).count).to be 0
        end
      end
    end
  end
end

require "spec_helper"
require "fontcustom/cli"

describe Fontcustom::CLI do
  context "#compile" do
    it "should generate fonts and templates (integration)", :integration => true do
      live_test do |testdir|
        Fontcustom::CLI.start ["compile", "vectors", "--quiet"]
        manifest = File.join testdir, ".fontcustom-manifest.json"
        preview = File.join testdir, "fontcustom", "fontcustom-preview.html"

        Dir.glob(File.join(testdir, "fontcustom", "fontcustom_*\.{ttf,svg,woff,eot}")).length.should eq(4)
        File.read(manifest).should match(/"fonts":.+fontcustom\/fontcustom_.+\.ttf"/m)
        File.exists?(preview).should be_true
      end
    end

    it "should generate fonts and templates according to passed options (integration)", :integration => true do
      live_test do |testdir|
        Fontcustom::CLI.start ["compile", "vectors", "--font-name", "example", "--no-hash", "--base64", "--quiet"]
        manifest = File.join testdir, ".fontcustom-manifest.json"
        css = Dir.glob(File.join("example", "*.css")).first

        File.read(manifest).should match(/"fonts":.+example\/example\.ttf"/m)
        File.read(css).should match("x-font-woff")
      end
    end
  end
end

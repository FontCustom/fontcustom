require "spec_helper"
require "fontcustom/cli"

describe Fontcustom::CLI do
  context "#compile" do
    it "should create a manifest file and set manifest[:options]" do
      live_test "create_manifest" do |test|
        Fontcustom::Base.any_instance.stub :start_generators
        Fontcustom::CLI.start ["compile", "vectors"]
        manifest = File.join test, ".fontcustom-manifest.json"
        File.exists?(manifest).should be_true
        File.read(manifest).should match(/"options":.+sandbox\/create_manifest\/fontcustom/m)
      end
    end

    it "should set manifest[:glyphs]" do
      live_test "set_glyphs" do |test|
        Fontcustom::Generator::Template.stub :new
        Fontcustom::CLI.start ["compile", "vectors", "--quiet"]
        manifest = File.join test, ".fontcustom-manifest.json"
        File.read(manifest).should match(/"glyphs":.+"c"/m)
      end
    end
  end
end

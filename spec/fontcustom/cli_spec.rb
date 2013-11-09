require "spec_helper"
require "fontcustom/cli"

describe Fontcustom::CLI do
  context "#compile" do
    it "should create a manifest file" do
      live_test "compile" do |test|
        Fontcustom::CLI.start ["compile", "vectors"]
        manifest = File.join test, ".fontcustom-manifest.json"
        json = File.read(manifest)
        File.exists?(manifest).should be_true
        json.should match(/sandbox\/compile\/fontcustom/)
      end
    end
  end
end

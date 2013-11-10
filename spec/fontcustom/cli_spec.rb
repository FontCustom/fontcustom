require "spec_helper"
require "fontcustom/cli"

describe Fontcustom::CLI do
  context "#compile" do
    it "should create a manifest file" do
      live_test "create_manifest" do |test|
        Fontcustom::CLI.any_instance.stub :start_generators
        Fontcustom::CLI.start ["compile", "vectors"]
        manifest = File.join test, ".fontcustom-manifest.json"
        json = File.read(manifest)

        File.exists?(manifest).should be_true
        json.should match(/sandbox\/#{test}\/fontcustom/)
      end
    end

    it "should create fonts"
  end
end

require "spec_helper"
require "fontcustom/cli"

describe Fontcustom::CLI do
  context "#compile" do
    it "should generate fonts and templates (integration)", :integration => true do
      live_test do |testdir|
        Fontcustom::CLI.start ["compile", "vectors", "--quiet"]
        manifest = File.join testdir, ".fontcustom-manifest.json"
        Dir.glob(File.join(testdir, "fontcustom", "fontcustom_*\.{ttf,svg,woff,eot}")).length.should == 4
        File.read(manifest).should match(/"fonts":.+fontcustom\/fontcustom_.+\.ttf"/m)
      end
    end
  end
end

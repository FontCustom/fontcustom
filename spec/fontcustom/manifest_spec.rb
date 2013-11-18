require "spec_helper"

describe Fontcustom::Manifest do
  context "#initialize" do
    it "should create a manifest file and set manifest[:options] (integration)", :integration => true do
      live_test do |testdir|
        capture(:stdout) do 
          options = Fontcustom::Options.new(:input => "vectors").options
          Fontcustom::Manifest.new(options)
        end
        manifest = File.read File.join(testdir, ".fontcustom-manifest.json")
        manifest.should match(/"options":.+sandbox\/test\/fontcustom/m)
      end
    end
  end
end

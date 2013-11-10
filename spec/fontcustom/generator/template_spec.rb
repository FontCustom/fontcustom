require "spec_helper"

describe Fontcustom::Generator::Template do
  context "#generate" do
    it "should generate templates (integration)", :integration => true do
      pending
      files = [
        fixture("shared/vectors"),
        fixture("shared/mixed-output"),
        fixture("generators/.fontcustom-manifest-fonts.json")
      ]
      live_test files do |testdir|
        FileUtil.mv "mixed-output", "fontcustom"
        manifest = ".fontcustom-manifest-fonts.json"
      end
    end
  end
end

require "spec_helper"

describe Fontcustom::Generator::Template do
  context "#initialize" do
    it "should raise error if not passed options" do
      expect { Fontcustom::Generator::Template.new }.to raise_error(ArgumentError)
    end
  end

  context "#start" do
    it "should show warning if no templates are specified"
  end

  context ".template_paths" do
    it "should convert symbols to correct paths"
  end

  context ".generate" do
    it "should run Fontcustom.templates for each template"
    it "should update .fontcustom-data with any files created"
  end
end

require "spec_helper"

describe Fontcustom::Generator::Template do
  context "#load_data" do
    it "should raise error if data file doesn't exist"
    it "should assign @data from data file"
    it "should raise an error if no templates are given"
  end

  context "#copy_template" do
    it "should raise error if template does not exist"
    it "should update @data[:files] and data file"
  end
end

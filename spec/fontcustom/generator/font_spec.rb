require "spec_helper"

describe Fontcustom::Generator::Font do
  context "#check_input" do
    it "should raise error if input doesn't exist"
    it "should raise error if input isn't a directory"
    it "should raise error if input doesn't contain vectors"
  end

  context "#check_output" do
    it "should raise an error if output isn't a directory"
    it "should create output dir and data file if they don't exist"
    it "should assign @data from data file"
  end

  context "#reset_output" do
    it "should delete files from @data[:files]"
    it "should not delete non-generated files"
    it "should empty @data[:files] and update data file"
  end

  context "#generate" do
    it "should call fontforge"
    it "should options to fontforge"
    it "should raise error if fontforge fails"
  end

  context "#collect_data" do
    it "should assign @data from updated data file (TODO implement this in generate.py"
    it "should parse output for file names (TEMP)"
    it "should parse input for icon names (TEMP)"
    it "should assign @data[:files] and @data[:icons] and update data file (TEMP)" 
  end

  context "#announce_files" do
    it "should print generated files to console"
  end
end

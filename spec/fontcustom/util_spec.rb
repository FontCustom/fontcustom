require 'spec_helper'

describe Fontcustom::Util do
  context ".check_fontforge" do
    it "should raise error if fontforge isn't installed"
  end

  context ".parse_options" do
    it "should return a hash of all options"
    it "should overwrite defaults with config file"
    it "should overwrite config file and defaults with CLI options"
    it "should normalize font names"
    it "should expand template paths"
  end
end
